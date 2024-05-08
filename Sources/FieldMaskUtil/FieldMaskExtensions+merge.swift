import Foundation
import SwiftProtobuf

extension FieldMaskExtensions {
  public mutating func merge(
    from other: any FieldMaskExtensions,
    options: MergeOptions = MergeOptions()
  ) throws {
    guard let other = other as? Self else {
      throw FieldMaskErrors.mergingDifferentMessageTypes
    }
    let fieldMask = Google_Protobuf_FieldMask(forAllFieldsIn: self)
    try self.merge(from: other, with: fieldMask, options: options)
  }

  public mutating func merge(
    from other: any FieldMaskExtensions,
    with fieldMask: Google_Protobuf_FieldMask,
    options: MergeOptions = MergeOptions()
  ) throws {
    guard let other = other as? Self else {
      throw FieldMaskErrors.mergingDifferentMessageTypes
    }
    let tree = FieldMaskTree(from: fieldMask)
    try tree.mergeMessage(from: other, to: &self, options: options)
  }

  public func merging(
    from other: any FieldMaskExtensions,
    options: MergeOptions = MergeOptions()
  ) throws -> Self {
    var result = self
    try result.merge(from: other, options: options)
    return result
  }

  public func merging(
    from other: any FieldMaskExtensions,
    with fieldMask: Google_Protobuf_FieldMask,
    options: MergeOptions = MergeOptions()
  ) throws -> Self {
    var result = self
    try result.merge(from: other, with: fieldMask, options: options)
    return result
  }
}

// Options controlling how fields are merged.
public struct MergeOptions {
  public var replaceMessageFields = false
  public var replaceRepeatedFields = false

  public init() {}
}
