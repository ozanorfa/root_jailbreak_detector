// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "root_jailbreak_detector",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // Flutter's generated plugin package references this product with
        // hyphens, so the name must not match the underscored target name.
        .library(name: "root-jailbreak-detector", targets: ["root_jailbreak_detector"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "root_jailbreak_detector",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
