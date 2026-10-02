// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Luma",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Luma",
            targets: ["Luma"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Luma",
            path: "Luma",
            exclude: ["Resources/Info.plist"]
        )
    ]
)
