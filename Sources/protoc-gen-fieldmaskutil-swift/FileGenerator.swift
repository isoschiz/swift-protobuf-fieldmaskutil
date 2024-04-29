import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

// private func kpappend<T: FieldMaskDescripted>(_ root: PartialKeyPath<T>, _ kp: AnyKeyPath) -> PartialKeyPath<T> {
//   let appended = root.appending(path: kp)
//   return appended!
// }

// private let _tmp: [FieldMaskUtilFieldDescriptor<Core_Foundation_Users_GetResponse>] = _fieldDescriptorsForCore_Foundation_Users_User.map {
//   FieldMaskUtilFieldDescriptor<Core_Foundation_Users_GetResponse>(
//     name: "user." + $0.name,
//     keyPath: kpappend(\Core_Foundation_Users_GetResponse.user, $0.keyPath),
//     isRepeated: $0.isRepeated,
//     isMessage: $0.isMessage,
//     isRequired: $0.isRequired,
//     messageType: $0.messageType,
//     isSubmessageField: true
//   )
// }

@available(macOS 13.0, *)
extension Generator {
  internal func printFieldMaskExtensions() {

    // var repeatedFields: Set<String> = []
    // var messageFields: Set<String> = []
    // var requiredFields: Set<String> = []

    let fullName = protobufNamer.fullName(message: message)
    guard !seenFields.contains(fullName) else {
      return
    }
    seenFields.insert(fullName)

    var descriptors: [String] = [fieldDescriptorsVarName]
    // self.println("private let " + keyPathsVarName + ": [" + keyPathsType + ": String] = [", newline: !message.fields.isEmpty)
    // if message.fields.isEmpty {
    //   self.println(":]")
    // } else {
    //   for field in message.fields {
    //     self.field = field
    //     let fieldNames = protobufNamer.messagePropertyNames(field: field, prefixed: "", includeHasAndClear: false)
    //     self.withIndentation {
    //       self.println("\\." + fieldNames.name + ": " + quoted(field.name) + ",")
    //     }

    //     //if field.isRequired {
    //     //  requiredFields.insert(fieldNames.name)
    //     //}
    //     if case .repeated = field.label {
    //       repeatedFields.insert(fieldNames.name)
    //     }
    //     if case .message = field.type {
    //       messageFields.insert(fieldNames.name)
    //     }
    //   }
    //   self.println("]")
    // }
    if message.fields.isEmpty {
      self.println("private let \(fieldDescriptorsVarName): [\(fieldDescriptorsType)] = []")
    } else {
      // Print sub fields first.
      for field in message.fields {
        if case .message = field.type, let messageType = field.messageType {
          // TODO: fix this: needs to be only if this is a subtype of this type.
          if let _ = messageType.containingType, messageType.file.name == file.name {
            let priorMessage = self.message
            self.message = field.messageType!
            self.printFieldMaskExtensions()
            self.message = priorMessage
          }

          self.printSubtypeFieldDescriptors(for: field)
          self.println()
          descriptors.append(fieldDescriptorsSubtypeVarName(for: field))
        }
      }
      self.println("private let \(fieldDescriptorsVarName): [\(fieldDescriptorsType)] = [")
      for field in message.fields {
        self.field = field
        let fieldNames = protobufNamer.messagePropertyNames(field: field, prefixed: "", includeHasAndClear: false)
        self.withIndentation {
          self.println("\(fieldDescriptorsType)(")
          self.withIndentation {
            self.println("name: \(quoted(field.name)),")
            self.println("keyPath: \\.\(fieldNames.name),")
            self.println("isRepeated: \(field.label == .repeated),")
            self.println("isMessage: \(field.type == .message),")
            self.println("isRequired: false,") // TODO: fix this
            let subtypeName = field.type == .message ? "\(protobufNamer.fullName(message: field.messageType!)).self" : "nil"
            self.println("messageType: \(subtypeName)")
          }
          self.println("),")
        }
      }
      self.println("]")
    }
    // self.println("private let " + repeatedVarName + ": Set<" + keyPathsType + "> = [")
    // for field in repeatedFields {
    //   self.withIndentation {
    //     self.println("\\." + field + ",")
    //   }
    // }
    // self.println("]")
    // self.println("private let " + messageVarName + ": Set<" + keyPathsType + "> = [")
    // for field in messageFields {
    //   self.withIndentation {
    //     self.println("\\." + field + ",")
    //   }
    // }
    // self.println("]")
    // self.println("private let " + requiredVarName + ": Set<" + keyPathsType + "> = [")
    // for field in requiredFields {
    //   self.withIndentation {
    //     self.println("\\." + field + ",")
    //   }
    // }
    // self.println("]")
    self.println()
    self.println("extension " + fullName + ": FieldMaskDescripted {")
    self.withIndentation {
      self.println("public static var fieldMaskDescriptor: FieldMaskUtilDescriptor<Self> = { FieldMaskUtilDescriptor<Self>(")
      self.withIndentation {
        self.println("descriptors: \(descriptors.joined(separator: " + "))")
        // self.println("repeatedFields: " + repeatedVarName + ",")
        // self.println("messageFields: " + messageVarName + ",")
        // self.println("requiredFields: " + requiredVarName)
      }
      self.println(")}()")
    }
    self.println("}")
    self.println()
    self.println("extension \(fullName): FieldMaskWritable {}")
    self.println("extension \(fullName): FieldMaskExtended {}")
    self.println()
  }

  internal func printSubtypeFieldDescriptors(for field: FieldDescriptor) {
    precondition(field.type == .message)
//    precondition(field.messageType!.containingType != nil)
    let subMessage = field.messageType!
    let subMessageName = protobufNamer.fullName(message: subMessage)
    let fieldName = protobufNamer.messagePropertyNames(field: field, prefixed: "", includeHasAndClear: false).name
//    self.println("private let \(fieldDescriptorsSubtypeVarName(for: field)): [\(fieldDescriptorsType)] = \(fieldDescriptorsVarName(for: subMessage)).map {")
    self.println("private let \(fieldDescriptorsSubtypeVarName(for: field)): [\(fieldDescriptorsType)] = \(subMessageName).fieldMaskDescriptor.fields.map {")
    self.withIndentation {
      self.println("\(fieldDescriptorsType)(")
      self.withIndentation {
        self.println("from: $0,")
        self.println("baseName: \(quoted(fieldName)),")
        self.println("rootKeyPath: \\\(messageFullName).\(fieldName)")
        // self.println("name: \(quoted(fieldName + ".")) + $0.name,")
        // self.println("keyPath: keyPathAppend(\\\(messageFullName).\(fieldName), $0.keyPath),")
        // self.println("isRepeated: $0.isRepeated,")
        // self.println("isMessage: $0.isMessage,")
        // self.println("isRequired: $0.isRequired,")
        // self.println("messageType: $0.messageType,")
        // self.println("isSubmessageField: true")
      }
      self.println(")")
    }
    self.println("}")
  }

  internal func printFunction(
    name: String,
    arguments: [String],
    returnType: String?,
    access: String? = nil,
    sendable: Bool = false,
    async: Bool = false,
    throws: Bool = false,
    genericWhereClause: String? = nil,
    bodyBuilder: (() -> Void)?
  ) {
    // Add a space after access, if it exists.
    let functionHead = (access.map { $0 + " " } ?? "") + (sendable ? "@Sendable " : "")
    let `return` = returnType.map { " -> " + $0 } ?? ""
    let genericWhere = genericWhereClause.map { " " + $0 } ?? ""

    let asyncThrows: String
    switch (async, `throws`) {
    case (true, true):
      asyncThrows = " async throws"
    case (true, false):
      asyncThrows = " async"
    case (false, true):
      asyncThrows = " throws"
    case (false, false):
      asyncThrows = ""
    }

    let hasBody = bodyBuilder != nil

    if arguments.isEmpty {
      // Don't bother splitting across multiple lines if there are no arguments.
      self.println(
        "\(functionHead)func \(name)()\(asyncThrows)\(`return`)\(genericWhere)",
        newline: !hasBody
      )
    } else {
      self.println("\(functionHead)func \(name)(")
      self.withIndentation {
        // Add a comma after each argument except the last.
        arguments.forEach(
          beforeLast: {
            self.println($0 + ",")
          },
          onLast: {
            self.println($0)
          }
        )
      }
      self.println(")\(asyncThrows)\(`return`)\(genericWhere)", newline: !hasBody)
    }

    if let bodyBuilder = bodyBuilder {
      self.println(" {")
      self.withIndentation {
        bodyBuilder()
      }
      self.println("}")
    }
  }
}
extension Array {
  /// Like `forEach` except that the `body` closure operates on all elements except for the last,
  /// and the `last` closure only operates on the last element.
  fileprivate func forEach(beforeLast body: (Element) -> Void, onLast last: (Element) -> Void) {
    for element in self.dropLast() {
      body(element)
    }
    if let lastElement = self.last {
      last(lastElement)
    }
  }
}
