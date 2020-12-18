// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ImageCropper",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "ImageCropper",
      type: .dynamic,
      targets: ["ImageCropper"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "ImageCropper",
      dependencies: []),
    .testTarget(
      name: "ImageCropperTests",
      dependencies: ["ImageCropper"]),
  ],
  swiftLanguageVersions: [.v5]
)
