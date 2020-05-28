// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZetaPushNetwork",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ZetaPushNetwork",
            targets: ["ZetaPushNetwork"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
      .package(name: "CometDClient", url: "https://github.com/Insurlytech/CometDClient-iOS.git", .upToNextMajor(from: "1.0.0")),
//      .package(name: "CometDClient", path: "../CometDClient-iOS"), //AGU
      .package(url: "https://github.com/hkellaway/Gloss.git", .upToNextMajor(from: "3.1.0")),
      .package(url: "https://github.com/mxcl/PromiseKit", .upToNextMajor(from: "6.13.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ZetaPushNetwork",
            dependencies: [
              "CometDClient",
              "Gloss",
              "PromiseKit"
        ]),
        .testTarget(
            name: "ZetaPushNetworkTests",
            dependencies: ["ZetaPushNetwork"]),
    ]
)
