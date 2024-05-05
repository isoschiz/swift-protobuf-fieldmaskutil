import Foundation
import SwiftProtobuf

// Workaround for https://github.com/apple/swift/issues/57560
extension AnyKeyPath: @unchecked Sendable {}

/// Helper function to coerce types when appending KeyPaths.
///
/// Note: the target type of `root`` must match the source type of `keyPath``.
private func keyPathAppend<T: FieldMaskDescripted>(
  _ root: PartialKeyPath<T>,
  _ keyPath: AnyKeyPath
) -> PartialKeyPath<T> {
  return root.appending(path: keyPath)!
}

/// Builds arrays of `FieldMaskUtilFieldDescriptor`s.
///
/// This builder should be used via the `build()` static function on `FieldMaskUtilDescriptor`.
@resultBuilder
public struct FieldDescriptorBuilder<T: FieldMaskDescripted> {
  public typealias FieldDescriptor = FieldMaskUtilFieldDescriptor<T>
  public static func buildBlock() -> [FieldDescriptor] {
    []
  }
  public static func buildExpression(_ expression: FieldDescriptor) -> [FieldDescriptor] {
    [expression]
  }
  public static func buildExpression(_ expression: [FieldDescriptor]) -> [FieldDescriptor] {
    expression
  }
  public static func buildBlock(_ components: [FieldDescriptor]...) -> [FieldDescriptor] {
    components.flatMap { $0 }
  }
  public static func buildOptional(_ components: [FieldDescriptor]?) -> [FieldDescriptor] {
    components ?? []
  }
  public static func buildEither(first components: [FieldDescriptor]) -> [FieldDescriptor] {
    components
  }
  public static func buildEither(second components: [FieldDescriptor]) -> [FieldDescriptor] {
    components
  }
  public static func buildArray(_ components: [[FieldDescriptor]]) -> [FieldDescriptor] {
    components.flatMap { $0 }
  }
  public static func buildLimitedAvailability(_ components: [FieldDescriptor]) -> [FieldDescriptor] {
    components
  }
}

/// Descriptor for a field - limited to the parameters needed by this package.
/// 
/// Note: all parameters are intentionally internal, and these descriptors are
/// not intended to be used by others. Access the public API via the extensions
/// on `Google_Protobuf_FieldMask`, and extensions on `Message` generated via
/// `protoc-genfieldmaskutil-swift`.
public struct FieldMaskUtilFieldDescriptor<T: FieldMaskDescripted>: Sendable {
  let name: String
  let keyPath: PartialKeyPath<T>
  let isRepeated: Bool
  let isMessage: Bool
  let isRequired: Bool
  let messageType: (any FieldMaskDescripted.Type)?
  let isSubmessageField: Bool

  /// Extends the given field descriptors with the given `baseName` and `rootKeyPath`.
  /// 
  /// - Parameters:
  ///   - fields: a list of fields. The `Root` of each pathKey must be the same type
  ///     as the `Value` of the given `rootKeyPath`.
  ///   - baseName: the base path to prepend to each path in the given fields.
  ///   - rootKeyPath: the root key path to prepend to each key path in the given
  ///     fields. As mentioned above, the `Value` of this key path must be the
  ///     same as the `Root` of each keyPath in `fields`.
  /// - Returns: an Array of field descriptors, anchored the given `baseName` and
  ///   `rootKeyPath`.
  public static func allFrom(
    _ fields: [FieldMaskUtilFieldDescriptor<some FieldMaskDescripted>],
    baseName: String,
    rootKeyPath: PartialKeyPath<T>
  ) -> [FieldMaskUtilFieldDescriptor<T>] {
    fields.map {
      FieldMaskUtilFieldDescriptor<T>(
        from: $0, baseName: baseName, rootKeyPath: rootKeyPath)
    }
  }

  /// Initialiser for building descriptors from sub-fields.
  /// 
  /// - Parameters:
  ///   - field: a field descriptor. The `Root` of the pathKey must be the same type
  ///     as the `Value` of the given `rootKeyPath`.
  ///   - baseName: the base path to prepend to the path in the given field.
  ///   - rootKeyPath: the root key path to prepend to the key path in the given
  ///     field. As mentioned above, the `Value` of this key path must be the
  ///     same as the `Root` of the keyPath in `field`.
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

  /// Standard memberwise initialiser.
  /// 
  /// - Parameters:
  ///   - name: the path name for this field.
  ///   - keyPath: the key path representing access to this field within its Message.
  ///   - isRepeated: whether the path points to a repeated proto field.
  ///   - isMessage: whether the path points to a field with a message type.
  ///   - isRequired: whether the path points to a required field.
  ///   - messageType: the type of the message. Only set if isMessage is true.
  ///   - isSubmessageField: true if this is a submessage field, and not a field
  ///     in the top-level Message.
  public init(
    name: String,
    keyPath: PartialKeyPath<T>,
    isRepeated: Bool = false,
    isMessage: Bool = false,
    isRequired: Bool = false,
    messageType: (any FieldMaskDescripted.Type)? = nil,
    isSubmessageField: Bool = false
  ) {
    precondition(!isMessage || messageType != nil)
    self.name = name
    self.keyPath = keyPath
    self.isRepeated = isRepeated
    self.isMessage = isMessage
    self.isRequired = isRequired
    self.messageType = messageType
    self.isSubmessageField = isSubmessageField
  }

  /// Builder wrapping the initialiser.
  static func with(
    name: String,
    keyPath: PartialKeyPath<T>,
    isRepeated: Bool = false,
    isMessage: Bool = false,
    isRequired: Bool = false,
    messageType: (any FieldMaskDescripted.Type)? = nil,
    isSubmessageField: Bool = false
  ) -> Self {
    return Self(
      name: name,
      keyPath: keyPath,
      isRepeated: isRepeated,
      isMessage: isMessage,
      isRequired: isRequired,
      messageType: messageType,
      isSubmessageField: isSubmessageField
    )
  }
}

// Descriptor for a Message - suitable only for user by FieldMaskUtil.
public struct FieldMaskUtilDescriptor<T: FieldMaskDescripted>: Sendable {
  public let fields: [FieldMaskUtilFieldDescriptor<T>] 
  let keyPaths: [PartialKeyPath<T>: String]
  let inverseKeyPaths: [String: PartialKeyPath<T>]
  let repeatedFields: Set<PartialKeyPath<T>>
  let messageFields: Set<PartialKeyPath<T>>
  let requiredFields: Set<PartialKeyPath<T>>

  /// Builder to construct a descriptor from a FieldDescriptorBuilder.
  /// 
  /// - Parameter builder: the builder to use.
  /// - Returns: a new descriptor, using field descriptors from the given builder.
  public static func build(
    @FieldDescriptorBuilder<T> _ builder: () -> [FieldMaskUtilFieldDescriptor<T>]
  ) -> FieldMaskUtilDescriptor<T> {
    Self.init(descriptors: builder())
  }

  /// Initialise from a set of FieldDescriptors.
  /// 
  /// Consider using the builder instead.
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

/// Protocol for any Messages that have a FieldMaskUtilDescriptor.
public protocol FieldMaskDescripted: Message {
  /// Accessor for the descriptor for this Message type.
  static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> { get }

  /// Validates that the given path is contained within the set of fields in the descriptor.
  /// 
  /// - Parameter path: the path to check validity of.
  /// - Returns: whether the given `path` is valid for this Message type.
  static func isValidPath(_ path: String) -> Bool
}

extension FieldMaskDescripted {
  /// Default implementation.
  public static func isValidPath(_ path: String) -> Bool {
    return fieldMaskDescriptor.inverseKeyPaths[path] != nil
  }
}
