# RealityCheck

![Icon](./Assets/Icon.png)

> **Important**
> If you are looking to use RealityCheck with visionOS, take a look to the [feature/visionOS](https://github.com/monstar-lab-oss/reality-check/tree/feature/visionOS) branch. It is nearing completion and will soon be merged 🥽
> 
> [![Sneak Peek](https://img.youtube.com/vi/89iYsoWBrME/hqdefault.jpg)](https://www.youtube.com/embed/89iYsoWBrME)

**RealityCheck** is an open-source Mac app designed to help AR development teams streamline their workflows and improve the quality of their projects. It provides a debugger for RealityKit, a powerful framework for building AR experiences, that allows developers to inspect the [Entity Component System (ECS)](https://developer.apple.com/documentation/realitykit/implementing-systems-for-entities-in-a-scene) structure and properties, and make changes in real-time for preview/debug purposes.

![Screenshot](./Assets/Screenshot.png)

## Features

- Inspect and modify entity and component properties in real-time for debugging and preview purposes
- Stream the current state of your AR app to the RealityCheck debugger in real-time
- Support for custom representations for different types of properties, such as transform matrices and light intensity
- Built with SwiftUI and [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) for clean, modular code and a great user experience

## Getting Started


To use RealityCheck in your AR project, you'll need to import the RealityCheck library and connect to a live session running on an iOS device. Please refer to the [Documentation](https://monstar-lab-oss.github.io/reality-check/documentation/realitycheckconnect/) for detailed instructions on how to integrate RealityCheck into your project.

## Thanks

[Yasuhito Nagatomo](https://www.atarayosd.com) is an inspiration with the highly useful [RealityDump.swift](https://gist.github.com/ynagatomo/86d8e88cebeb36be5c2164ddc3f427c8) helper and his many contributions to the field.

[Max Cobb](https://maxxfrazer.medium.com/) thanks for all your articles and repositories. Many roadblocks have been cleared up because of this.

[Andy Jazz](https://medium.com/@arkit) there's no related question in stack overflow that he hasn't answered (and many times created) in the best way possible.

## Contributing


We welcome contributions from the AR development community! If you'd like to contribute to RealityCheck, please see our [Contributing Guidelines](https://github.com/monstar-lab/reality-check/CONTRIBUTING.md) for instructions on how to get started.

## License


RealityCheck is released under the [MIT License](https://github.com/monstar-lab/reality-check/LICENSE).

## Contact


If you have any questions or feedback about RealityCheck, please contact us at [cristian.diaz@monstar-lab.com]. We'd love to hear from you!

That's just a rough example, but I hope it gives you an idea of what to include in your README. Let me know if you have any questions or need any further assistance!

## References

- [Understanding RealityKit’s modular architecture](https://developer.apple.com/documentation/visionOS/understanding-the-realitykit-modular-architecture)
- [Immersive experiences](https://developer.apple.com/design/human-interface-guidelines/immersive-experiences)
- [Spatial layout](https://developer.apple.com/design/human-interface-guidelines/spatial-layout)
- [ORIGAMI FUJIMOTO CUBE (Shuzo Fujimoto)](https://www.youtube.com/watch?v=Y8ljs9s9yqI)
