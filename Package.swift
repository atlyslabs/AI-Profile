// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "ATAIProfile",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ATAIProfile",
            targets: ["ATAIProfile"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/atlyslabs/ATCore.git", from: "1.0.16"),
        .package(url: "https://github.com/atlyslabs/ATUIKit", from: "1.3.7"),
        .package(url: "https://github.com/atlyslabs/ATAuthKit.git", from: "1.0.44"),
        .package(url: "https://github.com/atlyslabs/ditto-migrate-toolkit.git", from: "0.0.1"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit.git", from: "3.6.0"),
        .package(url: "https://github.com/kean/Nuke.git", from: "12.0.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "14.0.0"),
    ],
    targets: [
        .target(
            name: "ATAIProfile",
            dependencies: [
                .product(name: "ATCore", package: "ATCore"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "ATUIKit", package: "ATUIKit"),
                .product(name: "ATAuthKit", package: "ATAuthKit"),
                .product(name: "DittoRuntimeStrings", package: "ditto-migrate-toolkit"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "Nuke", package: "Nuke"),
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "ATAIProfileTests",
            dependencies: ["ATAIProfile"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
