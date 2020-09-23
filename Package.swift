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
      .package(name: "CometDClient", url: "https://github.com/Insurlytech/CometDClient-iOS.git", .exact("1.1.3")),
//      .package(name: "CometDClient", path: "../CometDClient-iOS"), //AGU
      .package(url: "https://github.com/hkellaway/Gloss.git", .exact("3.2.1")),
      .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.13.3")),
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
