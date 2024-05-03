import Foundation
import SwiftProtobuf

public enum FieldMaskErrors: Error {
  case keyPathNotFound(AnyKeyPath)
  case pathNotFound(String)
  case nonWritableKeyPath(AnyKeyPath)
  case snakeCaseContainsUppercaseChar(String)
  case charAfterUnderscoreMustBeLowercase(String)
  case trailingUnderscore(String)
  case camelCaseContainsUnderscore(String)
  case repeatedFieldNotCollection(String)
  case messageFieldNotMessage(String)
  case mergingDifferentMessageTypes
}

extension String {
  fileprivate static let fieldMaskSeparator = ","

  fileprivate func snakeCaseToCamelCase() throws -> String {
    var result = [Character]()
    var afterUnderscore = false
    for char in self {
      if char.isASCII && char.isUppercase {
        throw FieldMaskErrors.snakeCaseContainsUppercaseChar(self)
      }
      if afterUnderscore {
        if char.isASCII && char.isLowercase {
          result.append(contentsOf: char.uppercased())
          afterUnderscore = false
        } else {
          throw FieldMaskErrors.charAfterUnderscoreMustBeLowercase(self)
        }
      } else if char == "_" {
        afterUnderscore = true
      } else {
        result.append(char)
      }
    }
    if afterUnderscore {
      throw FieldMaskErrors.trailingUnderscore(self)
    }
    return String(result)
  }

  fileprivate func camelCaseToSnakeCase() throws -> String {
    var result = [Character]()
    for char in self {
      if char == "_" {
        throw FieldMaskErrors.camelCaseContainsUnderscore(self)
      }
      if char.isASCII && char.isUppercase {
        result.append("_")
        result.append(contentsOf: char.lowercased())
      } else {
        result.append(char)
      }
    }
    return String(result)
  }
}

// To and from strings.
extension Google_Protobuf_FieldMask {
  public init(fromString string: String) {
    self.init()
    self.paths = string
      .components(separatedBy: String.fieldMaskSeparator)
      .filter { !$0.isEmpty }
  }

  public func toString() -> String {
    return self.paths.joined(separator: .fieldMaskSeparator)
  }

  init(fromJsonString jsonString: String) throws {
    self.init()
    self.paths = try jsonString
      .components(separatedBy: String.fieldMaskSeparator)
      .filter { !$0.isEmpty }
      .map { try $0.camelCaseToSnakeCase() }
  }

  func toJsonString() throws -> String {
    return try self.paths
      .map { try $0.snakeCaseToCamelCase() }
      .joined(separator: .fieldMaskSeparator)
  }
}

// Initialising FieldMasks.
extension Google_Protobuf_FieldMask {
  public init<T: FieldMaskDescripted>(
    fromKeyPaths keyPaths: [PartialKeyPath<T>]
  ) throws {
    self.init()
    try keyPaths.forEach {
      guard self.addKeyPath($0) else {
        throw FieldMaskErrors.keyPathNotFound($0)
      }
    }
  }

  public init<T: FieldMaskDescripted>(forAllFieldsIn type: T.Type) {
    self.init()
    for (_, path) in T.fieldMaskDescriptor.keyPaths {
      self.paths.append(path)
    }
  }

  public init<T: FieldMaskDescripted>(forAllFieldsIn message: T) {
    self.init(forAllFieldsIn: type(of: message))
  }
}

// Manipulating the paths.
extension Google_Protobuf_FieldMask {
  public func isValid<T: FieldMaskDescripted>(for type: T.Type) -> Bool {
    return self.paths.allSatisfy {
      T.isValidPath($0)
    }
  }

  public func isValid<T: FieldMaskDescripted>(for message: T) -> Bool {
    return self.isValid(for: type(of: message))
  }

  func containsPath(_ query: String) -> Bool {
    for path in self.paths {
      if path == query || query.hasPrefix(path + ".") {
        return true
      }
    }
    return false
  }

  func containsKeyPath<T: FieldMaskDescripted>(
    _ query: PartialKeyPath<T>
  ) throws -> Bool {
    guard let path = T.fieldMaskDescriptor.keyPaths[query] else {
      throw FieldMaskErrors.keyPathNotFound(query)
    }
    return self.containsPath(path)
  }

  func stripping(prefix: String) -> Google_Protobuf_FieldMask {
    // TODO: remove this and handle complex prefixes.
    precondition(!prefix.contains("."))
    var newMask = Google_Protobuf_FieldMask()
    for path in self.paths {
      let parts = path.split(separator: ".", maxSplits: 1)
      if parts[0] == prefix && parts.count > 1 {
        newMask.paths.append(String(parts[1]))
      }
    }
    return newMask
  }

  func stripping<T: FieldMaskDescripted>(
    root: PartialKeyPath<T>
  ) throws -> Google_Protobuf_FieldMask {
    guard let path = T.fieldMaskDescriptor.keyPaths[root] else {
      throw FieldMaskErrors.keyPathNotFound(root)
    }
    return self.stripping(prefix: path)
  }

  @discardableResult
  public mutating func addPath<T: FieldMaskDescripted>(
    _ path: String,
    for: T
  ) -> Bool {
    guard T.isValidPath(path) else {
      return false
    }
    self.paths.append(path)
    return true
  }

  @discardableResult
  public mutating func addKeyPath<T: FieldMaskDescripted>(
    _ keyPath: PartialKeyPath<T>
  ) -> Bool {
    guard let path = T.fieldMaskDescriptor.keyPaths[keyPath] else {
      return false
    }
    self.paths.append(path)
    return true
  }

  public func toCanonicalForm() -> Self {
    let tree = FieldMaskTree(from: self)
    return tree.asFieldMask
  }
}

// Combining FieldMasks.
extension Google_Protobuf_FieldMask {
  func union(
    _ fieldMask: Google_Protobuf_FieldMask
  ) -> Google_Protobuf_FieldMask {
    let tree = FieldMaskTree(from: self)
    tree.addPaths(from: fieldMask)
    return tree.asFieldMask
  }

  func intersect(
    _ fieldMask: Google_Protobuf_FieldMask
  ) -> Google_Protobuf_FieldMask {
    var result = FieldMaskTree()
    let tree = FieldMaskTree(from: fieldMask)
    for path in fieldMask.paths {
      result += tree.intersectPath(path)
    }
    return result.asFieldMask
  }

  func subtract<T: FieldMaskDescripted>(
    _ fieldMask: Google_Protobuf_FieldMask,
    for type: T.Type
  ) -> Google_Protobuf_FieldMask {
    if self.paths.isEmpty {
      return Google_Protobuf_FieldMask()
    }
    let tree = FieldMaskTree(from: self)
    for path in fieldMask.paths {
      tree.removePath(path, of: type)
    }
    return tree.asFieldMask
  }

  func subtract<T: FieldMaskDescripted>(
    _ fieldMask: Google_Protobuf_FieldMask,
    for message: T
  ) -> Google_Protobuf_FieldMask {
    return self.subtract(fieldMask, for: type(of: message))
  }
}
