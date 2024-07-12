// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileCachePackage",
    products: [
        .library(
            name: "FileCachePackage",
            targets: ["FileCachePackage"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FileCachePackage",
            dependencies: []),
        .testTarget(
            name: "FileCachePackageTests",
            dependencies: ["FileCachePackage"])
    ]
)
