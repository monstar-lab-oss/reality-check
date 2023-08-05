import Dependencies
import Foundation
import Models
import MultipeerClient
import RealityKit
import SwiftUI
import StreamingClient
import RealityDumpClient

@Observable
final public class RealityCheckConnectViewModel {
  var connectionState: MultipeerClient.SessionState
  var hostName: String
  var isStreaming = false
  var content: RealityViewContent!
  
  public init(
    connectionState: MultipeerClient.SessionState = .notConnected,
    hostName: String = "..."
  ) {
    self.connectionState = connectionState
    self.hostName = hostName
    Task {
      await startMultipeerSession()
    }
  }
  
  func startMultipeerSession() async {
    @Dependency(\.multipeerClient) var multipeerClient
    
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
             await sendMultipeerData(content)
          }
          
        case .didReceiveData(let data):
          //FIXME: display debug options
          return
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
  
  public func sendMultipeerData(_ content: RealityViewContent) async {
    @Dependency(\.multipeerClient) var multipeerClient
    @Dependency(\.realityDump) var realityDump
    
    let encoder = JSONEncoder()
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "INF",
      negativeInfinity: "-INF",
      nan: "NAN"
    )
    encoder.outputFormatting = .prettyPrinted
    
    guard let root = content.root else { return }
    let identifiableEntity = await realityDump.identify(root)
    
    let realityViewData = try! encoder.encode(identifiableEntity)
    multipeerClient.send(realityViewData)
  }
  
  func startVideoStreaming() async {
    @Dependency(\.multipeerClient) var multipeerClient
    @Dependency(\.streamingClient) var streamingClient
    
    await MainActor.run {
      isStreaming = true
    }
    
    for await frameData in await streamingClient.startScreenCapture() {
      multipeerClient.send(frameData)
    }
  }
  
  func stopVideoStreaming() async {
    @Dependency(\.streamingClient) var streamingClient
    
    await MainActor.run {
      isStreaming = false
    }
    
    streamingClient.stopScreenCapture()
  }
}

extension RealityView {
  public init(
    _ realityCheckConnectViewModel: RealityCheckConnectViewModel,
    make: @escaping @MainActor @Sendable (inout RealityViewContent) async -> Void,
    update: (@MainActor (inout RealityViewContent) -> Void)? = nil
  ) where Content == RealityViewContent.Body<RealityViewDefaultPlaceholder> {
    self.init(
      make: { @MainActor content in
        await make(&content)
        realityCheckConnectViewModel.content = content
      },
      update: { @MainActor content in
        update?(&content)
        if case .connected = realityCheckConnectViewModel.connectionState {
          Task { [content] in
            await realityCheckConnectViewModel.sendMultipeerData(content)
          }
        }
      }
    )
  }
}