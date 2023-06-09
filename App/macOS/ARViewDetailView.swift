import Models
import SwiftUI

struct ARViewDetailView: View {
  let arView: CodableARView

  init(
    _ arView: CodableARView
  ) {
    self.arView = arView
  }

  var body: some View {
    Form {
      Section("View") {
        LabeledContent("contentScaleFactor", value: "\(arView.contentScaleFactor)")
      }
    }
    .formStyle(.grouped)
  }
}
