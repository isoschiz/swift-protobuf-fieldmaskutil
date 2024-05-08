import Foundation
import SwiftProtobuf

public protocol FieldMaskWritable {
  init()
  static func write<T>(keyPath: PartialKeyPath<T>, object: inout T, value: Any) throws
  static func write<T>(keyPath: PartialKeyPath<T>, object: inout T, value: Any?) throws

  func write<T>(to object: inout T, at keyPath: PartialKeyPath<T>) throws
}

extension FieldMaskWritable {
  public func write<T>(to object: inout T, at keyPath: PartialKeyPath<T>) throws {
    guard let path = keyPath as? WritableKeyPath<T, Self> else {
      throw FieldMaskErrors.nonWritableKeyPath(keyPath)
    }
    object[keyPath: path] = self
  }

  public static func write<T>(
    keyPath: PartialKeyPath<T>,
    object: inout T,
    value: Any
  ) throws {
    guard let path = keyPath as? WritableKeyPath<T, Self> else {
      throw FieldMaskErrors.nonWritableKeyPath(keyPath)
    }
    object[keyPath: path] = value as! Self
  }
  public static func write<T>(
    keyPath: PartialKeyPath<T>,
    object: inout T,
    value: Any?
  ) throws {
    guard let path = keyPath as? WritableKeyPath<T, Self?> else {
      throw FieldMaskErrors.nonWritableKeyPath(keyPath)
    }
    object[keyPath: path] = value as! Self?
  }
}

extension Array: FieldMaskWritable where Element: FieldMaskWritable {}
extension Optional: FieldMaskWritable where Wrapped: FieldMaskWritable {
    public init() {
        self = nil
    }
}

extension String: FieldMaskWritable {}
extension Bool: FieldMaskWritable {}
extension Double: FieldMaskWritable {}
extension Float: FieldMaskWritable {}
extension Int64: FieldMaskWritable {}
extension UInt64: FieldMaskWritable {}
extension Int32: FieldMaskWritable {}
extension UInt32: FieldMaskWritable {}
extension Data: FieldMaskWritable {}
