// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PokemonUIKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "PokemonUIKit",
            targets: ["PokemonUIKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/gmhz7b/CommonKit.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/gmhz7b/PokemonFoundation.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "PokemonUIKit",
            dependencies: [
                "CommonKit",
                "PokemonFoundation"
            ],
            resources: [.process("Resources")]
        )
    ]
)
