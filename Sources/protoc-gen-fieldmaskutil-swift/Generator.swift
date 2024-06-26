import SwiftProtobufPluginLibrary

class Generator {
  internal var options: GeneratorOptions
  private var printer: CodePrinter

  internal var file: FileDescriptor
  internal var message: Descriptor!  // context during generation
  internal var field: FieldDescriptor!  // context during generation

  internal var seenFields: Set<String> = []

  internal let protobufNamer: SwiftProtobufNamer

  init(_ file: FileDescriptor, options: GeneratorOptions) {
    self.file = file
    self.options = options
    self.printer = CodePrinter()
    self.protobufNamer = SwiftProtobufNamer(
      currentFile: file,
      protoFileToModuleMappings: options.protoToModuleMappings
    )
    self.printMain()
  }

  public var code: String {
    return self.printer.content
  }

  internal func println(_ text: String = "", newline: Bool = true) {
    self.printer.print(text)
    if newline {
      self.printer.print("\n")
    }
  }

  internal func indent() {
    self.printer.indent()
  }

  internal func outdent() {
    self.printer.outdent()
  }

  internal func withIndentation(body: () -> Void) {
    self.indent()
    body()
    self.outdent()
  }

  internal enum Braces {
    case none
    case curly
    case round
    case square

    var open: String {
      switch self {
      case .none:
        return ""
      case .curly:
        return "{"
      case .round:
        return "("
      case .square:
        return "["
      }
    }

    var close: String {
      switch self {
      case .none:
        return ""
      case .curly:
        return "}"
      case .round:
        return ")"
      case .square:
        return "]"
      }
    }
  }

  internal func withIndentation(
    _ header: String,
    braces: Braces,
    trailingComma: Bool = false,
    _ body: () -> Void
  ) {
    let spaceBeforeOpeningBrace: Bool
    switch braces {
    case .curly:
      spaceBeforeOpeningBrace = true
    case .round, .square, .none:
      spaceBeforeOpeningBrace = false
    }

    self.println(header + "\(spaceBeforeOpeningBrace ? " " : "")" + "\(braces.open)")
    self.withIndentation(body: body)
    self.println(braces.close + "\(trailingComma ? "," : "")")
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
      self.withIndentation("", braces: .curly) {
        bodyBuilder()
      }
    }
  }

  private func printMain() {
    self.printer.print(
      """
      //
      // DO NOT EDIT.
      // swift-format-ignore-file
      //
      // Generated by the protocol buffer compiler.
      // Source: \(self.file.name)
      //\n
      """
    )

    let moduleNames = [
      self.options.fieldMaskUtilModuleName,
      self.options.swiftProtobufModuleName,
    ]

    for moduleName in (moduleNames + self.options.extraModuleImports).sorted() {
      self.println("import \(moduleName)")
    }
    // Add imports for required modules
    let moduleMappings = self.options.protoToModuleMappings
    for importedProtoModuleName in moduleMappings.neededModules(forFile: self.file) ?? [] {
      self.println("import \(importedProtoModuleName)")
    }
    self.println()

    self.printPrivateFuncs()
    self.println()

    for message in self.file.messages {
      self.message = message
      self.printFieldMaskExtensions()
    }
  }

  private func printPrivateFuncs() {
    self.printFunction(
      name: "keyPathAppend<T: FieldMaskDescripted>",
      arguments: ["_ root: PartialKeyPath<T>", "_ keyPath: AnyKeyPath"],
      returnType: "PartialKeyPath<T>",
      access: "private"
    ) {
      self.println("return root.appending(path: keyPath)!")
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
