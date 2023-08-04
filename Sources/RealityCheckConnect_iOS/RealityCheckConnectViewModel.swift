import Dependencies
import Models
import MultipeerClient
import RealityDumpClient
import RealityKit
import StreamingClient
import SwiftUI

final class ViewModel: RealityCheckConnectable, ObservableObject {
  @Published var connectionState: MultipeerClient.SessionState
  @Published var hostName: String
  @Published var isStreaming = false

  @Dependency(\.multipeerClient) var multipeerClient
  @Dependency(\.realityDump) var realityDump
  @Dependency(\.streamingClient) var streamingClient

  var arView: ARView?

  init(
    connectionState: MultipeerClient.SessionState = .notConnected,
    hostName: String = "...",
    arView: ARView? = nil
  ) {
    self.connectionState = connectionState
    self.hostName = hostName
    self.arView = arView
  }

  func startMultipeerSession() async {
    //MARK: 1. Setup
    for await action in await multipeerClient.start(
      serviceName: "reality-check",
      sessionType: .peer,
      discoveryInfo: AppInfo.discoveryInfo
    ) {
      switch action {
        case .session(let sessionAction):
          switch sessionAction {
            case .stateDidChange(let state):
              await MainActor.run {
                connectionState = state
              }
              if case .connected = state {
                //MARK: 2. Send Hierarchy
                await sendMultipeerData()
              }

            case .didReceiveData(let data):
              //ARView Debug Options
              if let debugOptions = try? JSONDecoder()
                .decode(
                  _DebugOptions.self,
                  from: data
                )
              {
                await MainActor.run {
                  arView?.debugOptions = ARView.DebugOptions(
                    rawValue: debugOptions.rawValue
                  )
                }
              }
          }

        case .browser(_):
          return

        case .advertiser(let advertiserAction):
          switch advertiserAction {
            case .didReceiveInvitationFromPeer(let peer):
              multipeerClient.acceptInvitation()
              multipeerClient.stopAdvertisingPeer()
              await MainActor.run {
                hostName = peer.displayName
              }
          }
      }
    }
  }

  func sendMultipeerData() async {
    guard let arView else {
      //FIXME: make a runtime error instead
      fatalError("ARView is required in order to be able to send its hierarchy")
    }

    let encoder = JSONEncoder()
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "INF",
      negativeInfinity: "-INF",
      nan: "NAN"
    )
    encoder.outputFormatting = .prettyPrinted

    let anchors = await arView.scene.anchors.compactMap { $0 }
    var identifiableAnchors: [IdentifiableEntity] = []
    for anchor in anchors {
      identifiableAnchors.append(
        await realityDump.identify(anchor)
      )
    }

    #if os(iOS)
      let arViewData = try! await encoder.encode(
        CodableARView(
          arView,
          anchors: identifiableAnchors,
          contentScaleFactor: arView.contentScaleFactor
        )
      )
      multipeerClient.send(arViewData)
      print(String(data: arViewData, encoding: .utf8)!)
    #else
      fatalError("`arView.contentScaleFactor` cant be found on macOS")
    #endif
  }

  func startVideoStreaming() async {
    await MainActor.run {
      isStreaming = true
    }

    for await frameData in await streamingClient.startScreenCapture() {
      multipeerClient.send(frameData)
    }
  }

  func stopVideoStreaming() async {
    await MainActor.run {
      isStreaming = false
    }

    streamingClient.stopScreenCapture()
  }
}
