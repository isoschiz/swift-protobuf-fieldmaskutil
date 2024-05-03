import Foundation
import SwiftProtobuf

public protocol FieldMaskWritable {
  init()
  static func write<T>(keyPath: PartialKeyPath<T>, object: inout T, value: Any) throws
  static func write<T>(keyPath: PartialKeyPath<T>, object: inout T, value: Any?) throws
}

extension FieldMaskWritable {
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

extension String: FieldMaskWritable {}
extension Bool: FieldMaskWritable {}
extension Double: FieldMaskWritable {}
extension Float: FieldMaskWritable {}
extension Int64: FieldMaskWritable {}
extension UInt64: FieldMaskWritable {}
extension Int32: FieldMaskWritable {}
extension UInt32: FieldMaskWritable {}
extension Data: FieldMaskWritable {}
