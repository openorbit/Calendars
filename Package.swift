// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Calendars",

    platforms: [
      .macOS(.v26)
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Calendars",
            targets: ["Calendars"]),

        // Tools for working with the library
        .executable(name: "RomanTableTool", targets: ["RomanTableTool"]),

    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Calendars"),

        .executableTarget(
            name: "RomanTableTool",
            dependencies: [
              "Calendars",
              .product(name: "ArgumentParser", package: "swift-argument-parser"),
              .product(name: "SwiftCSV", package: "SwiftCSV"),
            ],
            path: "Sources/Tools/RomanTableTool"
        ),

        .testTarget(
            name: "CalendarsTests",
            dependencies: ["Calendars"]
        ),
    ]
)
