import Foundation
import SwiftProtobuf

// Enums used in the standard types.
extension Google_Protobuf_Syntax: FieldMaskWritable {}
extension Google_Protobuf_NullValue: FieldMaskWritable {}
extension Google_Protobuf_Field.Kind: FieldMaskWritable {}
extension Google_Protobuf_Field.Cardinality: FieldMaskWritable {}

extension Google_Protobuf_Any: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "type_url",
        keyPath: \.typeURL
      ),
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_Any: FieldMaskWritable {}
extension Google_Protobuf_Any: FieldMaskExtensions {}

extension Google_Protobuf_Api: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "name",
        keyPath: \.name
      ),
      .with(
        name: "methods",
        keyPath: \.methods,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Method.self
      ),
      .with(
        name: "options",
        keyPath: \.options,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Option.self
      ),
      .with(
        name: "version",
        keyPath: \.version
      ),
      .with(
        name: "source_context",
        keyPath: \.sourceContext,
        isMessage: true,
        messageType: Google_Protobuf_SourceContext.self
      ),
      .with(
        name: "source_context.file_name",
        keyPath: \.sourceContext.fileName,
        isSubmessageField: true
      ),
      .with(
        name: "mixins",
        keyPath: \.mixins,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Mixin.self
      ),
      .with(
        name: "syntax",
        keyPath: \.syntax
      ),
    ]
  )}()
}
extension Google_Protobuf_Api: FieldMaskWritable {}
extension Google_Protobuf_Api: FieldMaskExtensions {}

extension Google_Protobuf_BoolValue: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_BoolValue: FieldMaskWritable {}
extension Google_Protobuf_BoolValue: FieldMaskExtensions {}

extension Google_Protobuf_BytesValue: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_BytesValue: FieldMaskWritable {}
extension Google_Protobuf_BytesValue: FieldMaskExtensions {}

extension Google_Protobuf_DoubleValue: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_DoubleValue: FieldMaskWritable {}
extension Google_Protobuf_DoubleValue: FieldMaskExtensions {}

extension Google_Protobuf_Duration: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "seconds",
        keyPath: \.seconds
      ),
      .with(
        name: "nanos",
        keyPath: \.nanos
      ),
    ]
  )}()
}
extension Google_Protobuf_Duration: FieldMaskWritable {}
extension Google_Protobuf_Duration: FieldMaskExtensions {}

extension Google_Protobuf_Empty: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: []
  )}()
}
extension Google_Protobuf_Empty: FieldMaskWritable {}
extension Google_Protobuf_Empty: FieldMaskExtensions {}

extension Google_Protobuf_Field: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "kind",
        keyPath: \.kind
      ),
      .with(
        name: "cardinality",
        keyPath: \.cardinality
      ),
      .with(
        name: "number",
        keyPath: \.number
      ),
      .with(
        name: "name",
        keyPath: \.name
      ),
      .with(
        name: "type_url",
        keyPath: \.typeURL
      ),
      .with(
        name: "oneof_index",
        keyPath: \.oneofIndex
      ),
      .with(
        name: "packed",
        keyPath: \.packed
      ),
      .with(
        name: "options",
        keyPath: \.options,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Option.self
      ),
      .with(
        name: "json_name",
        keyPath: \.jsonName
      ),
      .with(
        name: "default_value",
        keyPath: \.defaultValue
      ),
    ]
  )}()
}
extension Google_Protobuf_Field: FieldMaskWritable {}
extension Google_Protobuf_Field: FieldMaskExtensions {}

extension Google_Protobuf_FieldMask: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      FieldMaskUtilFieldDescriptor<Self>(
        name: "paths",
        keyPath: \.paths
      ),
    ]
  )}()
}
extension Google_Protobuf_FieldMask: FieldMaskWritable {}
extension Google_Protobuf_FieldMask: FieldMaskExtensions {}

extension Google_Protobuf_FloatValue: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_FloatValue: FieldMaskWritable {}
extension Google_Protobuf_FloatValue: FieldMaskExtensions {}

extension Google_Protobuf_Int64Value: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_Int64Value: FieldMaskWritable {}
extension Google_Protobuf_Int64Value: FieldMaskExtensions {}

extension Google_Protobuf_ListValue: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "values",
        keyPath: \.values,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Value.self
      ),
    ]
  )}()
}
extension Google_Protobuf_ListValue: FieldMaskWritable {}
extension Google_Protobuf_ListValue: FieldMaskExtensions {}

extension Google_Protobuf_Method: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "name",
        keyPath: \.name
      ),
      .with(
        name: "request_type_url",
        keyPath: \.requestTypeURL
      ),
      .with(
        name: "request_streaming",
        keyPath: \.requestStreaming
      ),
      .with(
        name: "response_type_url",
        keyPath: \.responseTypeURL
      ),
      .with(
        name: "response_streaming",
        keyPath: \.responseStreaming
      ),
      .with(
        name: "options",
        keyPath: \.options,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Option.self
      ),
      .with(
        name: "syntax",
        keyPath: \.syntax
      ),
    ]
  )}()
}
extension Google_Protobuf_Method: FieldMaskWritable {}
extension Google_Protobuf_Method: FieldMaskExtensions {}

extension Google_Protobuf_Mixin: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "name",
        keyPath: \.name
      ),
      .with(
        name: "root",
        keyPath: \.root
      ),
    ]
  )}()
}
extension Google_Protobuf_Mixin: FieldMaskWritable {}
extension Google_Protobuf_Mixin: FieldMaskExtensions {}

extension Google_Protobuf_Option: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "name",
        keyPath: \.name
      ),
      .with(
        name: "value",
        keyPath: \.value,
        isMessage: true,
        messageType: Google_Protobuf_Any.self
      ),
    ]
  )}()
}
extension Google_Protobuf_Option: FieldMaskWritable {}
extension Google_Protobuf_Option: FieldMaskExtensions {}

extension Google_Protobuf_SourceContext: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "file_name",
        keyPath: \.fileName
      ),
    ]
  )}()
}
extension Google_Protobuf_SourceContext: FieldMaskWritable {}
extension Google_Protobuf_SourceContext: FieldMaskExtensions {}

extension Google_Protobuf_StringValue: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_StringValue: FieldMaskWritable {}
extension Google_Protobuf_StringValue: FieldMaskExtensions {}

extension Google_Protobuf_Struct: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "fields",
        keyPath: \.fields,
        isRepeated: true,
        isMessage: true
        // messageType: map<string, Value>
      ),
    ]
  )}()
}
extension Google_Protobuf_Struct: FieldMaskWritable {}
extension Google_Protobuf_Struct: FieldMaskExtensions {}

extension Google_Protobuf_Timestamp: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "seconds",
        keyPath: \.seconds
      ),
      .with(
        name: "nanos",
        keyPath: \.nanos
      ),
    ]
  )}()
}
extension Google_Protobuf_Timestamp: FieldMaskWritable {}
extension Google_Protobuf_Timestamp: FieldMaskExtensions {}

extension Google_Protobuf_Type: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "name",
        keyPath: \.name
      ),
      .with(
        name: "fields",
        keyPath: \.fields,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Field.self
      ),
      .with(
        name: "oneofs",
        keyPath: \.oneofs,
        isRepeated: true
      ),
      .with(
        name: "options",
        keyPath: \.options,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Option.self
      ),
      .with(
        name: "source_context",
        keyPath: \.sourceContext,
        isMessage: true,
        messageType: Google_Protobuf_SourceContext.self
      ),
      .with(
        name: "source_context.file_name",
        keyPath: \.sourceContext.fileName,
        isSubmessageField: true
      ),
      .with(
        name: "syntax",
        keyPath: \.syntax
      ),
      .with(
        name: "edition",
        keyPath: \.edition
      ),
    ]
  )}()
}
extension Google_Protobuf_Type: FieldMaskWritable {}
extension Google_Protobuf_Type: FieldMaskExtensions {}

extension Google_Protobuf_UInt32Value: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_UInt32Value: FieldMaskWritable {}
extension Google_Protobuf_UInt32Value: FieldMaskExtensions {}

extension Google_Protobuf_UInt64Value: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "value",
        keyPath: \.value
      ),
    ]
  )}()
}
extension Google_Protobuf_UInt64Value: FieldMaskWritable {}
extension Google_Protobuf_UInt64Value: FieldMaskExtensions {}

extension Google_Protobuf_Value: FieldMaskDescripted {
  public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(
    descriptors: [
      .with(
        name: "kind",
        keyPath: \.kind
      ),
      .with(
        name: "null_value",
        keyPath: \.nullValue
      ),
      .with(
        name: "number_value",
        keyPath: \.numberValue
      ),
      .with(
        name: "string_value",
        keyPath: \.stringValue
      ),
      .with(
        name: "bool_value",
        keyPath: \.boolValue
      ),
      .with(
        name: "struct_value",
        keyPath: \.structValue,
        isMessage: true,
        messageType: Google_Protobuf_Struct.self
      ),
      .with(
        name: "struct_value.fields",
        keyPath: \.structValue.fields,
        isRepeated: true,
        isMessage: true
        //messageType: map<string, Value>
      ),
      .with(
        name: "list_value",
        keyPath: \.listValue,
        isMessage: true,
        messageType: Google_Protobuf_ListValue.self
      ),
      .with(
        name: "list_value.values",
        keyPath: \.listValue.values,
        isRepeated: true,
        isMessage: true,
        messageType: Google_Protobuf_Value.self
      ),
  ])}()
}

// TODO: work out how to handle oneofs (Optional fields)
// Probably proto2 needs that too?
//extension Google_Protobuf_Value.OneOf_Kind: FieldMaskWritable {}

extension Google_Protobuf_Value: FieldMaskWritable {}
extension Google_Protobuf_Value: FieldMaskExtensions {}
