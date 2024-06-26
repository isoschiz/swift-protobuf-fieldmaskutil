import Foundation
import SwiftProtobuf

public enum PathElement<T: FieldMaskExtensions> {
  case keyPath(PartialKeyPath<T>)
  case path(String)
}

@resultBuilder
public struct FieldMaskBuilder<T: FieldMaskExtensions> {
  public static func buildBlock() -> [PathElement<T>] {
    []
  }
  public static func buildExpression(_ expression: String) -> [PathElement<T>] {
    [.path(expression)]
  }
  public static func buildExpression(_ expression: [String]) -> [PathElement<T>] {
    expression.map { .path($0) }
  }
  public static func buildExpression(_ expression: PartialKeyPath<T>) -> [PathElement<T>] {
    [.keyPath(expression)]
  }
  public static func buildExpression(_ expression: [PartialKeyPath<T>]) -> [PathElement<T>] {
    expression.map { .keyPath($0) }
  }
  public static func buildBlock(_ components: [PathElement<T>]...) -> [PathElement<T>] {
    components.flatMap { $0 }
  }
  public static func buildOptional(_ components: [PathElement<T>]?) -> [PathElement<T>] {
    components ?? []
  }
  public static func buildEither(first components: [PathElement<T>]) -> [PathElement<T>] {
    components
  }
  public static func buildEither(second components: [PathElement<T>]) -> [PathElement<T>] {
    components
  }
  public static func buildArray(_ components: [[PathElement<T>]]) -> [PathElement<T>] {
    components.flatMap { $0 }
  }
  public static func buildLimitedAvailability(_ components: [PathElement<T>]) -> [PathElement<T>] {
    components
  }
}

extension FieldMaskExtensions where Self: Message {
  public func buildFieldMask(
    @FieldMaskBuilder<Self> _ builder: () -> [PathElement<Self>]
  ) throws -> Google_Protobuf_FieldMask {
    let tree = FieldMaskTree()
    let elements = builder()
    for element in elements {
      switch element {
      case .path(let path):
        guard let _ = Self.fieldMaskDescriptor.inverseKeyPaths[path] else {
          throw FieldMaskErrors.pathNotFound(path)
        }
        _ = tree.addPath(path)
      case .keyPath(let keyPath):
        guard let path = Self.fieldMaskDescriptor.keyPaths[keyPath] else {
          throw FieldMaskErrors.keyPathNotFound(keyPath)
        }
        _ = tree.addPath(path)
      }
    }
    return tree.asFieldMask
  }
}
