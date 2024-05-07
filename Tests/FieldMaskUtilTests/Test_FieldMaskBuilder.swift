import Foundation
import XCTest
import SwiftProtobuf

import FieldMaskUtil

final class Test_FieldMaskBuilder: XCTestCase {
  let typeProto: Google_Protobuf_Type = .with {
    $0.name = "test_name.for_type"
    $0.sourceContext.fileName = "/foo/bar/filename.ext"
    $0.syntax = .proto3
  }

  func test_resultBuilder() throws {
    let fieldMask = try typeProto.buildFieldMask {
      \.sourceContext.fileName
      "syntax"
      \.name
    }

    assert(fieldMask.paths == ["name", "source_context.file_name", "syntax"])
  }

  func test_duplicated() throws {
    let fieldMask = try typeProto.buildFieldMask {
      \.sourceContext.fileName
      "syntax"
      \.name
      "source_context.file_name"
    }

    assert(
      fieldMask.paths == ["name", "source_context.file_name", "syntax"],
      "Unexpected paths: \(fieldMask.paths)"
    )
  }

  func test_overlapping() throws {
    let fieldMask = try typeProto.buildFieldMask {
      "syntax"
      \.name
      "source_context.file_name"
      \.sourceContext
    }

    assert(
      fieldMask.paths == ["name", "source_context", "syntax"],
      "Unexpected paths: \(fieldMask.paths)"
    )
  }

  func test_unknownPath() {
    do {
      let fieldMask = try typeProto.buildFieldMask {
        \.sourceContext.fileName
        "syntax"
        \.name
        "unknown_file.path"
      }
      assert(false, "Expected error - none thrown: \(fieldMask)")
    } catch FieldMaskErrors.pathNotFound(let path) {
      assert(path == "unknown_file.path")
    } catch {
      assert(false, "Unexpected error thrown: \(error)")
    }
  }

  func test_conditionals() throws {
    let syntax: String? = "syntax"
    let ignored: String? = nil
    let fieldMask = try typeProto.buildFieldMask {
      \.sourceContext.fileName
      if let syntax = syntax {
        syntax
      }
      \.name
      if let ignored = ignored {
        ignored
      }
    }

    assert(fieldMask.paths == ["name", "source_context.file_name", "syntax"])
  }

  func test_empty() throws {
    let fieldMask = try typeProto.buildFieldMask {}

    assert(fieldMask.paths == [], "Expected empty paths: \(fieldMask.paths)")
  }

  func test_arrays() throws {
    let fieldMask = try typeProto.buildFieldMask {
      [\.sourceContext.fileName, \.name, \.edition]
      ["syntax", "source_context.file_name"]
    }

    assert(fieldMask.paths == ["edition", "name", "source_context.file_name", "syntax"])
  }

  func test_branches() throws {
    let addSyntax = true
    let addEdition = false
    let fieldMask = try typeProto.buildFieldMask {
      \.sourceContext.fileName
      if addSyntax {
        \.syntax
      } else {
        "name"
      }
      if addEdition {
        "rubbish"
      } else {
        \.sourceContext
      }
    }

    assert(
      fieldMask.paths == ["source_context", "syntax"],
      "Expected specific paths: \(fieldMask.paths)"
    )
  }

  func test_loops() throws {
    let fieldMask = try typeProto.buildFieldMask {
      \.sourceContext.fileName
      for path in ["name", "syntax", "edition"] {
        path
      }
    }

    assert(
      fieldMask.paths == ["edition", "name", "source_context.file_name", "syntax"],
      "Expected specific paths: \(fieldMask.paths)"
    )
  }

  func test_availability() throws {
    let fieldMask = try typeProto.buildFieldMask {
      \.sourceContext.fileName
      if #available(macOS 13.0, *) {
        "syntax"
      }
      \.edition
    }

    assert(
      fieldMask.paths == ["edition", "source_context.file_name", "syntax"],
      "Expected specific paths: \(fieldMask.paths)"
    )
  }

  private func buildInvalidFieldMask() throws -> Google_Protobuf_FieldMask {
    return try typeProto.buildFieldMask {
      \.edition
      \.debugDescription
      \.sourceContext
    }
  }

  func test_invalidkeypath() throws {
    XCTAssertThrowsError(try buildInvalidFieldMask()) { error in
        XCTAssertEqual(
          error as! FieldMaskErrors,
          FieldMaskErrors.keyPathNotFound(\Google_Protobuf_Type.debugDescription))
    }    
  }
}
