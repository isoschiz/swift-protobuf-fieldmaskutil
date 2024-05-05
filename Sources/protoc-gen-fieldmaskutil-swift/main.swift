import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

enum Version {
  static let versionString = "0.1.0"
}

func Log(_ message: String) {
  FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
}

// from apple/swift-protobuf/Sources/protoc-gen-swift/StringUtils.swift
func splitPath(pathname: String) -> (dir: String, base: String, suffix: String) {
  var dir = ""
  var base = ""
  var suffix = ""
  #if swift(>=3.2)
  let pathnameChars = pathname
  #else
  let pathnameChars = pathname.characters
  #endif
  for c in pathnameChars {
    if c == "/" {
      dir += base + suffix + String(c)
      base = ""
      suffix = ""
    } else if c == "." {
      base += suffix
      suffix = String(c)
    } else {
      suffix += String(c)
    }
  }
  #if swift(>=3.2)
  let validSuffix = suffix.isEmpty || suffix.first == "."
  #else
  let validSuffix = suffix.isEmpty || suffix.characters.first == "."
  #endif
  if !validSuffix {
    base += suffix
    suffix = ""
  }
  return (dir: dir, base: base, suffix: suffix)
}

enum FileNaming: String {
  case FullPath
  case PathToUnderscores
  case DropPath
}

func outputFileName(
  component: String,
  fileDescriptor: FileDescriptor,
  fileNamingOption: FileNaming,
  extension: String
) -> String {
  let ext = "." + component + "." + `extension`
  let pathParts = splitPath(pathname: fileDescriptor.name)
  switch fileNamingOption {
  case .FullPath:
    return pathParts.dir + pathParts.base + ext
  case .PathToUnderscores:
    let dirWithUnderscores =
      pathParts.dir.replacingOccurrences(of: "/", with: "_")
    return dirWithUnderscores + pathParts.base + ext
  case .DropPath:
    return pathParts.base + ext
  }
}

func uniqueOutputFileName(
  component: String,
  fileDescriptor: FileDescriptor,
  fileNamingOption: FileNaming,
  generatedFiles: inout [String: Int],
  extension: String = "swift"
) -> String {
  let defaultName = outputFileName(
    component: component,
    fileDescriptor: fileDescriptor,
    fileNamingOption: fileNamingOption,
    extension: `extension`
  )
  if let count = generatedFiles[defaultName] {
    generatedFiles[defaultName] = count + 1
    return outputFileName(
      component: "\(count)." + component,
      fileDescriptor: fileDescriptor,
      fileNamingOption: fileNamingOption,
      extension: `extension`
    )
  } else {
    generatedFiles[defaultName] = 1
    return defaultName
  }
}

func printVersion(args: [String]) {
  // Stip off the file path
  let program = args.first?.split(separator: "/").last ?? "protoc-gen-fieldmaskutil-swift"
  print("\(program) \(Version.versionString)")
}

func main(args: [String]) throws {
  if args.dropFirst().contains("--version") {
    printVersion(args: args)
    return
  }

  // initialize responses
  var response = Google_Protobuf_Compiler_CodeGeneratorResponse(
    files: [],
    supportedFeatures: [.proto3Optional]
  )

  // read plugin input
  let rawRequest = FileHandle.standardInput.readDataToEndOfFile()
  let request = try Google_Protobuf_Compiler_CodeGeneratorRequest(serializedData: rawRequest)

  let options = try GeneratorOptions(parameter: request.parameter)

  // Build the SwiftProtobufPluginLibrary model of the plugin input
  let descriptorSet = DescriptorSet(protos: request.protoFile)

  // A count of generated files by desired name (actual name may differ to avoid collisions).
  var generatedFiles: [String: Int] = [:]

  // We need to generate output for all messages.
  for name in request.fileToGenerate {
    if let fileDescriptor = descriptorSet.fileDescriptor(named: name) {
      var fieldMaskUtilFile = Google_Protobuf_Compiler_CodeGeneratorResponse.File()
      let fieldMaskUtilFileName = uniqueOutputFileName(
        component: "fieldmaskutil",
        fileDescriptor: fileDescriptor,
        fileNamingOption: options.fileNaming,
        generatedFiles: &generatedFiles
      )
      let fieldMaskUtilGenerator = Generator(fileDescriptor, options: options)
      fieldMaskUtilFile.content = fieldMaskUtilGenerator.code
      fieldMaskUtilFile.name = fieldMaskUtilFileName
      response.file.append(fieldMaskUtilFile)
    }
  }

  // return everything to the caller
  let serializedResponse = try response.serializedData()
  FileHandle.standardOutput.write(serializedResponse)
}

do {
  try main(args: CommandLine.arguments)
} catch {
  Log("ERROR: \(error)")
}
