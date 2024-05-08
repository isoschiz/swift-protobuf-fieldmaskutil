import Foundation
import SwiftProtobuf

extension FieldMaskExtensions {
  @discardableResult
  public mutating func trim(
    with fieldMask: Google_Protobuf_FieldMask,
    options: TrimOptions = TrimOptions()
  ) throws -> Bool {
    // Make a copy of our original state so we can see if it changed.
    let original = self
    //let allFields = Self.fieldMaskDescriptor.keyPaths
    for path in fieldMask.paths { // TODO: we literally want the opposite of this!
      guard let keyPath = Self.fieldMaskDescriptor.inverseKeyPaths[path] else {
        throw FieldMaskErrors.pathNotFound(path)
      }
      let valueType = type(of: self[keyPath: keyPath]) as! any FieldMaskWritable.Type
      let newValue = valueType.init()
      try valueType.write(keyPath: keyPath, object: &self, value: newValue)    
    }
    return self != original
  }

  public func trimming(
    with fieldMask: Google_Protobuf_FieldMask,
    options: TrimOptions = TrimOptions()
  ) throws -> Self {
    var result = self
    try result.trim(with: fieldMask, options: options)
    return result
  }
}

// Options controlling how fields are trimmed.
public struct TrimOptions {
  // Note: Required fields not currently supported by the generator.
//  public var keepRequiredFields = false
  public init() {}
}
