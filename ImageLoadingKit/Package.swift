// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ImageLoadingKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ImageLoadingKit",
            targets: ["ImageLoadingKit"]
        )
    ],
    targets: [
        .target(name: "ImageLoadingKit"),
        .testTarget(
            name: "ImageLoadingKitTests",
            dependencies: ["ImageLoadingKit"]
        )
    ]
)
