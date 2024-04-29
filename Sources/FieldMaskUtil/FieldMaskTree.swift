import Foundation
import SwiftProtobuf

class FieldMaskTree {
  class Node: Equatable {
    let key: String
    var children: [String: Node] = [:]
    
    init(key: String, children: [String : Node] = [:]) {
      self.key = key
      self.children = children
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
      return lhs.key == rhs.key && lhs.children == rhs.children
    }
    
    func allPaths() -> [String] {
      if children.isEmpty {
        return [key]
      } else {
        return children.flatMap { _, node in
          node.allPaths().map { key.isEmpty ? $0 : "\(key).\($0)" }
        }.sorted()
      }
    }
  }
  var root = Node(key: "")
  
  init() {}
  
  init(from fieldMask: Google_Protobuf_FieldMask) {
    for path in fieldMask.paths {
      addPath(path)
    }
  }
  
  var asFieldMask: Google_Protobuf_FieldMask {
    return .with {
      $0.paths = root.allPaths()
    }
  }

  func addPaths(from fieldMask: Google_Protobuf_FieldMask) {
    for path in fieldMask.paths {
      self.addPath(path)
    }
  }
  
  func addPath(_ path: String) {
    var curr = root
    for segment in path.split(separator: ".") {
      let segment = String(segment)
      if let next = curr.children[segment] {
        curr = next
      } else {
        let next = Node(key: segment)
        curr.children[segment] = next
        curr = next
      }
    }
  }
  
  func removePath<T: FieldMaskDescripted>(_ path: String, of type: T.Type) {
    if !type.isValidPath(path) {
      // No changes needed if we're removing a path that isn't valid anyway.
      return
    }
    var prev = root
    var curr = root
    for segment in path.split(separator: ".") {
      let segment = String(segment)
      if let next = curr.children[segment] {
        (prev, curr) = (curr, next)
      } else {
        //it's already not present, return
        return
      }
    }
    if curr != prev {
      // We found the specific segment
      prev.children.removeValue(forKey: curr.key)
    }
  }

  func intersectPath(_ path: String) -> FieldMaskTree {
    let result = FieldMaskTree()
    var curr = root
    for segment in path.split(separator: ".") {
      let segment = String(segment)
      guard !curr.children.isEmpty else {
        if curr != root {
          result.addPath(path)
        }
        return result
      }
      guard let next = curr.children[segment] else {
        // No intersection found.
        return result
      }
      curr = next
    }
    result.mergeLeafNodes(prefix: path, node: curr)
    return result
  }

  func mergeMessage<T: FieldMaskDescripted>(
    from message: T,
    to destination: inout T,
    options: MergeOptions = MergeOptions()
  ) throws {
    if root.children.isEmpty {
      return
    }
    try mergeMessage(node: root, pathPrefix: root.key, from: message,to: &destination, options: options)
  }

  private func mergeMessage<T: FieldMaskDescripted>(
    node: Node,
    pathPrefix: String,
    from message: T,
    to destination: inout T,
    options: MergeOptions = MergeOptions()
  ) throws {
    precondition(!node.children.isEmpty)
    let descriptor = T.fieldMaskDescriptor

    for (_, child) in node.children {
      let path = pathPrefix.isEmpty ? child.key : "\(pathPrefix).\(child.key)"
      guard let field = descriptor.fields.first(where: {
        $0.name == path
      }) else {
        // TODO: Log this somehow.
        continue
      }
      guard let keyPath = field.keyPath as? WritableKeyPath<T, Any> else {
        throw FieldMaskErrors.nonWritableKeyPath(field.keyPath)
      }

      guard child.children.isEmpty else {
        // Sub-paths only allowed for singular message fields.
        guard !field.isRepeated && field.isMessage else {
          // TODO: Log this somehow
          continue
        }
        try self.mergeMessage(node: child, pathPrefix: path, from: message, to: &destination, options: options)
        continue
      }

      let newValue = message[keyPath: keyPath]
      let valueType = type(of: newValue) as! FieldMaskWritable.Type

      if !field.isRepeated {
        if field.isMessage {
          if options.replaceMessageFields {
            try valueType.write(keyPath: keyPath, object: &destination, value: newValue)
            //destination[keyPath: keyPath] = message[keyPath: keyPath]
          } else {
            guard let _ = destination[keyPath: keyPath] as? any FieldMaskExtended else {
              throw FieldMaskErrors.messageFieldNotMessage(path)
            }
            guard let source = message[keyPath: keyPath] as? any FieldMaskExtended else {
              throw FieldMaskErrors.messageFieldNotMessage(path)
            }
            var tmpValue = destination[keyPath: keyPath] as! any FieldMaskExtended
            try tmpValue.merge(from: source)
            try valueType.write(keyPath: keyPath, object: &destination, value: tmpValue)
            //destination[keyPath: keyPath] = tmpValue
          }
        } else { // !isMessage
          try valueType.write(keyPath: keyPath, object: &destination, value: newValue)
        }
      } else { // isRepeated
        if options.replaceRepeatedFields {
          try valueType.write(keyPath: keyPath, object: &destination, value: newValue)
        } else {
          guard let newValue = newValue as? Array<Any>, let oldValue = destination[keyPath: keyPath] as? Array<Any> else {
            throw FieldMaskErrors.repeatedFieldNotCollection(path)
          }
          try valueType.write(keyPath: keyPath, object: &destination, value: oldValue + newValue)
        }
      }
    }
  }

  static func +(left: FieldMaskTree, right: FieldMaskTree) ->  FieldMaskTree {
    let result = FieldMaskTree(from: left.asFieldMask)
    result.addPaths(from: right.asFieldMask)
    return result
  }

  static func +=(left: inout FieldMaskTree, right: FieldMaskTree) {
    left.addPaths(from: right.asFieldMask)
  }

  private func mergeLeafNodes(prefix: String, node: Node) {
    guard !node.children.isEmpty else {
      self.addPath(prefix)
      return
    }
    for (_, child) in node.children {
      let path = prefix.isEmpty ? child.key : "\(prefix).\(child.key)"
      mergeLeafNodes(prefix: path, node: child)
    }
  }
}
