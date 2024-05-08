import Foundation
import SwiftProtobuf

// Extensions to Message that allowing merging and trimming based on a FieldMask.
public protocol FieldMaskExtensions: Equatable, FieldMaskDescripted, Message {
  // Builder for FieldMasks for this Message type.
  func buildFieldMask(
    @FieldMaskBuilder<Self> _ builder: () -> [PathElement<Self>]
  ) throws -> Google_Protobuf_FieldMask

  // Merges all fields. Note other must be the same Message type or this throws.
  mutating func merge(
    from other: any FieldMaskExtensions,
    options: MergeOptions
  ) throws
  mutating func merge(
    from other: any FieldMaskExtensions,
    with fieldMask: Google_Protobuf_FieldMask,
    options: MergeOptions
  ) throws
  func merging(
    from other: any FieldMaskExtensions,
    options: MergeOptions
  ) throws -> Self
  func merging(
    from other: any FieldMaskExtensions,
    with fieldMask: Google_Protobuf_FieldMask,
    options: MergeOptions
  ) throws -> Self

  // Trims fields not mentioned in the fieldMask. Returns whether any changes were made.
  @discardableResult
  mutating func trim(
    with fieldMask: Google_Protobuf_FieldMask,
    options: TrimOptions
  ) throws -> Bool
  func trimming(
    with fieldMask: Google_Protobuf_FieldMask,
    options: TrimOptions
  ) throws -> Self
}
