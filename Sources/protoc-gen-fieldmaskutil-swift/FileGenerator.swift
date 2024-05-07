import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

extension Generator {
  internal func printFieldMaskExtensions() {
    let fullName = protobufNamer.fullName(message: message)
    // guard !seenFields.contains(fullName) else {
    //   println("// Attempt to double write FieldMaskExtensions for \(fullName)")
    //   return
    // }
    // seenFields.insert(fullName)

    let extraDescriptors: [FieldDescriptor] = message.fields.filter {
      field.type == .message && field.messageType != nil
    }
    // for field in message.fields {
    //   if case .message = field.type, let _ = field.messageType {
    //     extraDescriptors.append(field)
    //   }
    // }

    // Print types for nested types first.
    for subMessage in message.messages {
      let priorMessage = self.message
      self.message = subMessage
      self.printFieldMaskExtensions()
      self.message = priorMessage
    }

    if message.fields.isEmpty {
      self.println("private let \(fieldDescriptorsVarName): [\(fieldDescriptorsType)] = []")
    } else {
      self.withIndentation("private let \(fieldDescriptorsVarName): [\(fieldDescriptorsType)] = ", braces: .square) {
        for field in message.fields {
          self.field = field
          self.printFieldDescriptor()
        }
      }
    }
    self.println()
    self.withIndentation("extension \(fullName): FieldMaskDescripted", braces: .curly) {
      self.withIndentation("public static let fieldMaskDescriptor = FieldMaskUtilDescriptor<Self>.build", braces: .curly) {
        self.println(fieldDescriptorsVarName)
        for extraDescriptor in extraDescriptors {
          let fieldName = protobufNamer.messagePropertyNames(field: extraDescriptor, prefixed: "", includeHasAndClear: false).name
          self.withIndentation("FieldMaskUtilFieldDescriptor<Self>.allFrom", braces: .round) {
            self.println("\(fullNameFor(extraDescriptor.messageType!)).fieldMaskDescriptor.fields,")
            self.println("baseName: \(quoted(extraDescriptor.name)),")
            self.println("rootKeyPath: \\.\(fieldName)")
          }
        }
      }
    }
    self.println()
    self.println("extension \(fullName): FieldMaskWritable {}")
    self.println("extension \(fullName): FieldMaskExtensions {}")
    self.println()
  }

  private func printFieldDescriptor() {
    let fieldName = protobufNamer.messagePropertyNames(field: field, prefixed: "", includeHasAndClear: false).name
    self.withIndentation("\(fieldDescriptorsType)", braces: .round, trailingComma: true) {
      self.println("name: \(quoted(field.name)),")
      self.println("keyPath: \\.\(fieldName),")
      self.println("isRepeated: \(field.label == .repeated),")
      self.println("isMessage: \(field.type == .message),")
      self.println("isRequired: false,") // TODO: fix this
      self.println("messageType: \(fieldSubtypeName)")
    }
  }
}
