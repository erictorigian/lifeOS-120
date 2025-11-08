// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LifeOS120",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LifeOS120",
            targets: ["LifeOS120"])
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "LifeOS120",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
