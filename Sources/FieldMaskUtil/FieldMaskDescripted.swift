import Foundation
import SwiftProtobuf

// Helper function that does some type coercion for us.
// Note: the target type of root must match the source type of keyPath.
private func keyPathAppend<T: FieldMaskDescripted>(
  _ root: PartialKeyPath<T>,
  _ keyPath: AnyKeyPath
) -> PartialKeyPath<T> {
  return root.appending(path: keyPath)!
}

// Descriptor for a field - suitable only for use by FieldMaskUtil.
public struct FieldMaskUtilFieldDescriptor<T: FieldMaskDescripted> {
  let name: String
  let keyPath: PartialKeyPath<T>
  let isRepeated: Bool
  let isMessage: Bool
  let isRequired: Bool
  let messageType: (any FieldMaskDescripted.Type)?
  let isSubmessageField: Bool

  // Initialiser for building descriptors from sub-fields.
  public init(
    from field: FieldMaskUtilFieldDescriptor<some FieldMaskDescripted>,
    baseName: String,
    rootKeyPath: PartialKeyPath<T>
  ) {
    self.init(
      name: "\(baseName).\(field.name)",
      keyPath: keyPathAppend(rootKeyPath, field.keyPath),
      isRepeated: field.isRepeated,
      isMessage: field.isMessage,
      isRequired: field.isRequired,
      messageType: field.messageType,
      isSubmessageField: true)
  }

  // Standard initialiser.
  public init(
    name: String,
    keyPath: PartialKeyPath<T>,
    isRepeated: Bool = false,
    isMessage: Bool = false,
    isRequired: Bool = false,
    messageType: (any FieldMaskDescripted.Type)? = nil,
    isSubmessageField: Bool = false
  ) {
    self.name = name
    self.keyPath = keyPath
    self.isRepeated = isRepeated
    self.isMessage = isMessage
    self.isRequired = isRequired
    self.messageType = messageType
    self.isSubmessageField = isSubmessageField
  }

  // Builder wrapping the initialiser.
  static func with(
    name: String,
    keyPath: PartialKeyPath<T>,
    isRepeated: Bool = false,
    isMessage: Bool = false,
    isRequired: Bool = false,
    messageType: (any FieldMaskDescripted.Type)? = nil,
    isSubmessageField: Bool = false
  ) -> Self {
    return Self(name: name, keyPath: keyPath, isRepeated: isRepeated, isMessage: isMessage, isRequired: isRequired, messageType: messageType, isSubmessageField: isSubmessageField)
  }
}

// Descriptor for a Message - suitable only for user by FieldMaskUtil.
public struct FieldMaskUtilDescriptor<T: FieldMaskDescripted> {
  public let fields: [FieldMaskUtilFieldDescriptor<T>] 
  let keyPaths: [PartialKeyPath<T>: String]
  let inverseKeyPaths: [String: PartialKeyPath<T>]
  let repeatedFields: Set<PartialKeyPath<T>>
  let messageFields: Set<PartialKeyPath<T>>
  let requiredFields: Set<PartialKeyPath<T>>

  // Initialise from a set of FieldDescriptors.
  public init(
    descriptors: [FieldMaskUtilFieldDescriptor<T>]
  ) {
    self.fields = descriptors
    self.keyPaths = Dictionary(uniqueKeysWithValues: descriptors.map {
      ($0.keyPath, $0.name)
    })
    self.inverseKeyPaths = Dictionary(uniqueKeysWithValues: keyPaths.map { (key, value) in (value, key) })
    self.repeatedFields = Set(descriptors.filter { $0.isRepeated }.map { $0.keyPath })
    self.messageFields = Set(descriptors.filter { $0.isMessage }.map { $0.keyPath })
    self.requiredFields = Set(descriptors.filter { $0.isRequired }.map { $0.keyPath })
  }
}

// Protocol for any Messages that have a FieldMaskUtilDescriptor.
public protocol FieldMaskDescripted: Message {
  static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> { get }
  static func isValidPath(_ path: String) -> Bool
}

extension FieldMaskDescripted {
  public static func isValidPath(_ path: String) -> Bool {
    return fieldMaskDescriptor.inverseKeyPaths[path] != nil
  }
}
