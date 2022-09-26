// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hoa",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.4.3")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.2")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Hoa",
            dependencies: [
                .product(name: "CSV", package: "CSV.swift"),
                "Alamofire",
                "SwiftSoup",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [
                .copy("Resources/00_bestiaryDF.csv"),
                .copy("Resources/researchgate.json"),
            ]
        ),
    ]
)
