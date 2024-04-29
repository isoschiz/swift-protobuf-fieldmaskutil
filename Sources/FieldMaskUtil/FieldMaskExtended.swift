import Foundation
import SwiftProtobuf

// Extensions to Message that allowing merging and trimming based on a FieldMask.
public protocol FieldMaskExtended: Equatable, FieldMaskDescripted, Message {
  // Builder for FieldMasks for this Message type.
  func fieldMask(with builder: (inout FieldMaskBuilder<Self>) -> Void) -> Google_Protobuf_FieldMask where Self: Message
  // Merging all fields. Note other must be the same Message type or this throws.
  mutating func merge(from other: any FieldMaskExtended) throws
  mutating func merge(_ other: any FieldMaskExtended, with fieldMask: Google_Protobuf_FieldMask, options: MergeOptions) throws
  // Trims fields not mentioned in the fieldMask. Returns whether any changes were made.
  @discardableResult
  mutating func trim(with fieldMask: Google_Protobuf_FieldMask, options: TrimOptions) throws -> Bool
}

public struct FieldMaskBuilder<T: Message & FieldMaskExtended> {
  fileprivate var fieldMask = Google_Protobuf_FieldMask()
  public mutating func addKeyPath(_ keyPath: PartialKeyPath<T>) {
    fieldMask.addKeyPath(keyPath)
  }
}

extension FieldMaskExtended {
  public func fieldMask(with builder: (inout FieldMaskBuilder<Self>) -> Void) -> Google_Protobuf_FieldMask where Self: Message {
    var fieldMask = FieldMaskBuilder<Self>()
    builder(&fieldMask)
    return fieldMask.fieldMask
  }

  public mutating func merge(from other: any FieldMaskExtended) throws {
    guard let other = other as? Self else {
      throw FieldMaskErrors.mergingDifferentMessageTypes
    }
    let fieldMask = Google_Protobuf_FieldMask(forAllFieldsIn: self)
    try self.merge(other, with: fieldMask)
  }

  public mutating func merge(
    _ other: any FieldMaskExtended,
    with fieldMask: Google_Protobuf_FieldMask,
    options: MergeOptions = MergeOptions()
  ) throws {
    guard let other = other as? Self else {
      throw FieldMaskErrors.mergingDifferentMessageTypes
    }
    let tree = FieldMaskTree(from: fieldMask)
    try tree.mergeMessage(from: other, to: &self, options: options)
  }

  @discardableResult
  public mutating func trim(with fieldMask: Google_Protobuf_FieldMask, options: TrimOptions = TrimOptions()) throws -> Bool {
    // Make a copy of our original state so we can see if it changed.
    let original = self
    //let allFields = Self.fieldMaskDescriptor.keyPaths
    for path in fieldMask.paths { // TODO: we literally want the opposite of this!
      guard let keyPath = Self.fieldMaskDescriptor.inverseKeyPaths[path] else {
        throw FieldMaskErrors.pathNotFound(path)
      }
      let valueType = type(of: self[keyPath: keyPath]) as! FieldMaskWritable.Type
      let newValue = valueType.init()
      try valueType.write(keyPath: keyPath, object: &self, value: newValue)    
    }
    return self != original
  }
}

// Options controlling how fields are merged.
public struct MergeOptions {
  public var replaceMessageFields = false
  public var replaceRepeatedFields = false

  public init() {}
}

// Options controlling how fields are trimmed.
public struct TrimOptions {
  // Note: Required fields not currently supported by the generator.
//  public var keepRequiredFields = false
  public init() {}
}
