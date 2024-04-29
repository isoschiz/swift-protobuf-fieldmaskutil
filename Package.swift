// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
  static let protobuf: Self = .product(name: "SwiftProtobuf", package: "swift-protobuf")
  static let protobufPluginLibrary: Self = .product(
    name: "SwiftProtobufPluginLibrary",
    package: "swift-protobuf"
  )
}

let package = Package(
  name: "swift-protobuf-fieldmaskutil",
  products: [
    .executable(
      name: "protoc-gen-fieldmaskutil-swift",
      targets: ["protoc-gen-fieldmaskutil-swift"]
    ),
    .library(
      name: "FieldMaskUtil",
      targets: ["FieldMaskUtil"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-protobuf.git",
      from: "1.26.0"
    ),
    .package(
      url: "https://github.com/apple/swift-docc-plugin",
      from: "1.0.0"
    ),
  ],
  targets: [
    .executableTarget(
      name: "protoc-gen-fieldmaskutil-swift",
      dependencies: [
        .protobuf,
        .protobufPluginLibrary,
      ],
      path: "Sources/protoc-gen-fieldmaskutil-swift"
    ),
    .target(
      name: "FieldMaskUtil",
      dependencies: [
        .protobuf,
      ],
      path: "Sources/FieldMaskUtil"
    ),
  ]
)
