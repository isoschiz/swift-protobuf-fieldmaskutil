
import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary


private let swiftKeywordsUsedInDeclarations: Set<String> = [
  "associatedtype", "class", "deinit", "enum", "extension",
  "fileprivate", "func", "import", "init", "inout", "internal",
  "let", "open", "operator", "private", "protocol", "public",
  "static", "struct", "subscript", "typealias", "var",
]

private let swiftKeywordsUsedInStatements: Set<String> = [
  "break", "case",
  "continue", "default", "defer", "do", "else", "fallthrough",
  "for", "guard", "if", "in", "repeat", "return", "switch", "where",
  "while",
]

private let swiftKeywordsUsedInExpressionsAndTypes: Set<String> = [
  "as",
  "Any", "catch", "false", "is", "nil", "rethrows", "super", "self",
  "Self", "throw", "throws", "true", "try",
]

private let quotableFieldNames: Set<String> = { () -> Set<String> in
  var names: Set<String> = []

  names = names.union(swiftKeywordsUsedInDeclarations)
  names = names.union(swiftKeywordsUsedInStatements)
  names = names.union(swiftKeywordsUsedInExpressionsAndTypes)
  return names
}()

extension Generator {
  internal func fieldDescriptorsSubtypeVarName(for field: FieldDescriptor) -> String {
    let fieldName = protobufNamer.messagePropertyNames(field: field, prefixed: "", includeHasAndClear: false).name
    return "\(fieldDescriptorsVarName)__\(fieldName)" 
  }
  internal func fieldDescriptorsVarName(for thisMessage: Descriptor) -> String {
    return "_fieldDescriptorsFor\(fullNameFor(thisMessage).replacingOccurrences(of: ".", with: "__"))"
  }
  internal var fieldDescriptorsVarName: String {
    return fieldDescriptorsVarName(for: message)
  }
  internal func fullNameFor(_ thisMessage: Descriptor) -> String {
    return protobufNamer.fullName(message: thisMessage)
  }
  internal var messageFullName: String {
    return protobufNamer.fullName(message: message)
  }
  internal var fieldDescriptorsType: String {
    return "FieldMaskUtilFieldDescriptor<\(messageFullName)>"
  }
  internal var keyPathsType: String {
    return "PartialKeyPath<\(messageFullName)>"
  }

  internal func sanitize(fieldName string: String) -> String {
    if quotableFieldNames.contains(string) {
      return "`\(string)`"
    }
    return string
  }  
}

internal func quoted(_ str: String) -> String {
  return "\"" + str + "\""
}
