import Foundation
import SwiftProtobuf

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
}
