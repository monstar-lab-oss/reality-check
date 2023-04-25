import Foundation
import RealityKit

public struct IdentifiableEntity: Identifiable, Hashable {
    public let id: UInt64
    public var anchorIdentifier: UUID?
    public var name: String?
    public let type: EntityType
    public var children: [IdentifiableEntity]? {
        hierarhy.children.isEmpty ? nil : hierarhy.children
    }
    public var state: State
    public var hierarhy: Hierarhy
    public var components: Components

    public enum EntityType: Codable {
        case anchor
        case directionalLight
        case entity
        case model
        case perspectiveCamera
        case pointLight
        case spotLight
        case triggerVolume
    }

    public struct State: Equatable, Hashable {
        public let isEnabled: Bool
        public let isEnabledInHierarchy: Bool
        public let isActive: Bool
        public let isAnchored: Bool

        public init(
            isEnabled: Bool,
            isEnabledInHierarchy: Bool,
            isActive: Bool,
            isAnchored: Bool
        ) {
            self.isEnabled = isEnabled
            self.isEnabledInHierarchy = isEnabledInHierarchy
            self.isActive = isActive
            self.isAnchored = isAnchored
        }
    }

    public struct Hierarhy: Equatable, Hashable {
        public let hasParent: Bool
        public var childrenCount: Int { children.count }
        public var children: [IdentifiableEntity]

        public init(
            children: [IdentifiableEntity],
            hasParent: Bool
        ) {
            self.children = children
            self.hasParent = hasParent
        }
    }

    public struct Components: Equatable, Hashable {
        public let components: [IdentifiableComponent]
        public var count: Int { components.count }

        public init(
            components: [IdentifiableComponent]
        ) {
            self.components = components
        }
    }

    public init(
        id: UInt64,
        anchorIdentifier: UUID? = nil,
        name: String? = nil,
        type: EntityType,
        state: IdentifiableEntity.State,
        hierarhy: IdentifiableEntity.Hierarhy,
        components: IdentifiableEntity.Components
    ) {
        self.id = id
        self.anchorIdentifier = anchorIdentifier
        self.name = name
        self.type = type
        self.state = state
        self.hierarhy = hierarhy
        self.components = components
    }
}

extension IdentifiableEntity.EntityType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .anchor:
            return "AnchorEntity"
        case .directionalLight:
            return "DirectionalLight"
        case .entity:
            return "Entity"
        case .model:
            return "ModelEntity"
        case .perspectiveCamera:
            return "PerspectiveCamera"
        case .pointLight:
            return "PointLight"
        case .spotLight:
            return "SpotLight"
        case .triggerVolume:
            return "TriggerVolume"
        }
    }
}

extension IdentifiableEntity.EntityType {
    public var symbol: String {
        switch self {
        case .anchor:
            return "arrow.down.to.line"
        case .directionalLight:
            return "sun.max"
        case .entity:
            return "move.3d"
        case .model:
            return "cube"
        case .perspectiveCamera:
            return "camera"
        case .pointLight:
            return "lightbulb.led"
        case .spotLight:
            return "lamp.desk"
        case .triggerVolume:
            return "cube.transparent"
        }
    }
}

//MARK: -

extension Entity.ComponentSet: Equatable {
    //FIXME: Find a better way to use equatable or use another type instear `Entity.ComponentSet`

    public static func == (lhs: Entity.ComponentSet, rhs: Entity.ComponentSet) -> Bool {
        lhs.count == rhs.count
    }
}
