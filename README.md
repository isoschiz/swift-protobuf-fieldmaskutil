# Swift FieldMaskUtil

This repository contains an implementation of `FieldMaskUtil`, providing roughly
the same functionality as the C++ and Java implementations that are present in
the [protobuf repository](https://github.com/protocolbuffers/protobuf).

# What is a FieldMask?

A `google.protobuf.FieldMask` is a well-known proto that you would often include
in an update or read request to a server to influcnce how that request is
processed. See the protobuf [API guide](https://protobuf.dev/programming-guides/api/)
for examples of when to use one.

# Quick Start: How do I use FieldMaskUtil?

## Using merge(from:with:options:) in an Update RPC

Let's start with the example of an update RPC:

```protobuf
service MyService {
  rpc UpdateFoo(UpdateRequest) returns (UpdateResponse);
}

message Foo {
  string foo_name = 1;
  bool foo_enabled = 2;
  int32 foo_value = 3;
  SubMessage foo_details = 4;
}

message UpdateRequest {
  uint64 foo_id = 1
  Foo foo = 2;

  google.protobuf.FieldMask field_mask = 3;
}
```

On the server, when updating your `Foo`, you only want to overwrite fields that
were specified in the `FieldMask`. For this, you can use
`merge(from:with:options:)`, as follows:

```swift
func updateFoo(
  request: MyPackage_UpdateRequest,
  context: GRPCAsyncServerCallContext
) async throws -> MyPackage_UpdateResponse {
  var myFoo = try await fetchFoo(request.fooID)
  // We only care about the subset of the FieldMask affecting field "foo".
  let fieldMask = request.fieldMask.stripping(prefix: "foo")
  myFoo.merge(from: request.foo, with: fieldMask, options: MergeOptions())
  try await myStorage.write(myFoo)
  return .with { _ in }
}
```

This will only merge (update) fields that are specified in the `FieldMask`, and
leave any other fields at their current values. You can use `MergeOptions` to
control how `Message` and `repeated` sub-fields are merged.

Note: there is also a simple `merge(:options:)`, which merges all fields
from the source into the target.

## Using trim(with:options:) in a Read RPC

Now let's look at a Read RPC:

```protobuf
service MyService {
  rpc ReadFoo(ReadRequest) returns (ReadResponse);
}

message ReadRequest {
  uint64 foo_id = 1
  google.protobuf.FieldMask field_mask = 2;
}

message ReadResponse {
  uint64 foo_id = 1
  Foo foo = 2;

  google.protobuf.FieldMask field_mask = 3;
}
```

On the server, when returning your `Foo` details, you only want to return the
fields that have been requested in the `FieldMask`. For this, you can use
`trim(with:options:)`, as follows:

```swift
func readFoo(
  request: MyPackage_ReadRequest,
  context: GRPCAsyncServerCallContext
) async throws -> MyPackage_ReadResponse {
  let myFoo = try await fetchFoo(request.fooID)
  var response: MyPackage_ReadResponse = .with {
    $0.fooID = request.fooID
    $0.foo = myFoo
    $0.fieldMask = request.fieldMask
  }
  response.trim(with: request.fieldMask, options: TrimOptions())
  return response
}
```

This will clear the values for any fields not set in the `FieldMask`, reducing
the size of the response, and only giving the client the information they need.
You can use the `TrimOptions` to control how `required` fields are handled if
they are absent from the `FieldMask`.

## Building FieldMasks

If you need to create a `FieldMask` from scratch, the best way is to use the
builder:

```swift
var request: MyPackage_ReadRequest = .with {
  $0.fooID = myID
}
let fieldMask = myProto.buildFieldMask {
  \.foo.fooName
  \.foo.fooDetails
}
request.fieldMask = fieldMask
try await fooClient.readFoo(request)
```

When using the builder, you can leverage Swift's `KeyPath` literals to quickly
build up a `FieldMask` in a type-safe manner. You can, alternatively, use raw
string paths, and these will be type-checked by the builder:

```swift
let fieldMask = myProto.buildFieldMask {
  \.foo.fooName
  "foo.foo_value"
  "foo.foo_details"
}
```

Note that string path elements are written to match the field naming in your
protobuf file, and not using the Swift-ified names.

You can also build `FieldMasks`:
 - for all fields in a proto, with`init(forAllFieldsIn:)`;
 - with a specific set of `KeyPaths` with `init(fromKeyPaths:)`;
 - or directly add individual paths using `addPath` and `addKeyPath`.

## Manipulating FieldMasks

 - isValid(for:)
 - containsKey, containsKeyPath
 - stripping(prefix:), stripping(root:)
 - toCanonicalForm
 - union, intersect, subtract

 ## Converting to/from Strings

  - init(fromString:), init(fromJsonString:)
  - toString, toJsonString

# Setting up the Descriptor generator

...
