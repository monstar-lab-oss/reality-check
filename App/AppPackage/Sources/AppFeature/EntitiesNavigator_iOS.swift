import ComposableArchitecture
import Foundation
import Models
import RealityCodable

extension RealityPlatform.iOS.Entity {
  //FIXME: remove and use reality-codable existent properties
  public var computedName: String {
    if let name = self.name, !name.isEmpty {
      return name
    } else {
      return "\(type(of: self))"
    }
  }
}

extension RealityPlatform.iOS.Entity {
  public var systemImage: String {
    switch "\(type(of: self))" {
      case "AnchorEntity":
        return "arrow.down.to.line"
      case "Entity":
        return "move.3d"
      case "ModelEntity":
        return "cube"
      case "PerspectiveCamera":
        return "camera"
      case "TriggerVolume":
        return "cube.transparent"
      default:
        return "move.3d"
    }
  }
}

public struct EntitiesNavigator_iOS: Reducer {
  public struct State: Equatable {
    public var entities: IdentifiedArrayOf<RealityPlatform.iOS.Entity>

    @BindingState public var dumpOutput: String
    @BindingState public var selection: RealityPlatform.iOS.Entity.ID?

    public var selectedEntity: RealityPlatform.iOS.Entity? {
      guard let selection else { return nil }
      for rootEntity in entities {
        if let entity = RealityPlatform.iOS.Scene.findEntity(id: selection, root: rootEntity) {
          return entity
        }
      }
      return nil
    }

    public init(
      _ entities: [RealityPlatform.iOS.Entity],
      selection: RealityPlatform.iOS.Entity.ID? = nil
    ) {
      self.entities = .init(uniqueElements: entities)
      self.selection = selection ?? self.entities.first?.id
      self.dumpOutput = "⚠️ This can only be seen if the dump output is not received properly."
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case delegate(DelegateAction)
    case dumpOutput(String)
    case refreshEntities([RealityPlatform.iOS.Entity])
  }

  public enum DelegateAction: Equatable {
    case didToggleSelectSection
    case didSelectEntity(RealityPlatform.iOS.Entity.ID)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
        case .binding(\.$selection):
          if let entity = state.selectedEntity {
            return .merge(
              .send(.delegate(.didToggleSelectSection)),
              .send(.delegate(.didSelectEntity(entity.id)))
            )
          } else {
            return .send(.delegate(.didToggleSelectSection))
          }

        case .binding:
          return .none

        case .delegate(_):
          return .none

        case .dumpOutput(let output):
          state.dumpOutput = output
          return .none

        case .refreshEntities(let entities):
          state.entities = .init(uniqueElements: entities)
          guard let previousSelection = state.selection else { return .none }
          state.selection = nil
          return .send(.binding(.set(\.$selection, previousSelection)))
      }
    }
  }
}