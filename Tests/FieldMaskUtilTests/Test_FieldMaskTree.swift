import Foundation
import XCTest
import SwiftProtobuf

@testable import FieldMaskUtil

final class Test_FieldMaskTree: XCTestCase {
  let typeProto: Google_Protobuf_Type = .with {
    $0.name = "test_name.for_type"
    $0.sourceContext.fileName = "/foo/bar/filename.ext"
    $0.syntax = .proto3
  }

  let testProto: Fieldmasktest_FieldMaskTest = .with {
    $0.stringValue = "Hello"
  }

  func test_empty() throws {
    let tree = FieldMaskTree()
    let fieldMask = tree.asFieldMask
    XCTAssert(fieldMask.paths == [])
  }

  func test_fromfieldmask() throws {
    let testProtoFieldMask = try testProto.buildFieldMask {
      \.stringValue
      \.boolValue
    }

    let tree = FieldMaskTree(from: testProtoFieldMask)
    let fieldMask = tree.asFieldMask
    XCTAssert(fieldMask.paths == ["bool_value", "string_value"])
  }

  func test_addpathsfromfieldmask() throws {
    let fieldMaskBase = try testProto.buildFieldMask {
      \.stringValue
      \.boolValue
    }
    let fieldMaskAddition = try testProto.buildFieldMask {
      \.int32Value
      \.bytesValue
      \.stringValue
    }

    let tree = FieldMaskTree(from: fieldMaskBase)
    _ = tree.addPaths(from: fieldMaskAddition)
    let fieldMask = tree.asFieldMask
    XCTAssert(
      fieldMask.paths == ["bool_value", "bytes_value", "int32_value", "string_value"],
      "Expected specific field paths: \(fieldMask.paths)"
    )
  }

  func test_addparentpath() throws {
    let fieldMaskBase = try testProto.buildFieldMask {
      \.submessage.name
      \.submessage.value
      \.bytesValue
      \.uint32Value
    }

    let tree = FieldMaskTree(from: fieldMaskBase)
    _ = tree.addPath("submessage")
    let fieldMask = tree.asFieldMask
    XCTAssert(
      fieldMask.paths == ["bytes_value", "submessage", "uint32_value"],
      "Expected specific field paths: \(fieldMask.paths)"
    )
  }

  func test_addchildpath() throws {
    let fieldMaskBase = try testProto.buildFieldMask {
      \.submessage
      \.bytesValue
      \.uint32Value
    }

    let tree = FieldMaskTree(from: fieldMaskBase)
    _ = tree.addPath("submessage.name")
    let fieldMask = tree.asFieldMask
    XCTAssert(
      fieldMask.paths == ["bytes_value", "submessage", "uint32_value"],
      "Expected specific field paths: \(fieldMask.paths)"
    )
  }
}
