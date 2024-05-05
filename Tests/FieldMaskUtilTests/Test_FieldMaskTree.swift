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

  func test_empty() throws {
    let tree = FieldMaskTree()
    let fieldMask = tree.asFieldMask
    assert(fieldMask.paths == [])
  }
}
