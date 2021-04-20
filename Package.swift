// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SeaCat",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "SeaCat", targets: ["SeaCat"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SeaCat", path: "seacat"),
    ],
    swiftLanguageVersions: [.v5]
)
