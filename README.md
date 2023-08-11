# FLite

*FLite is a streamlined Swift ORM for using [FluentSQLiteDriver](https://github.com/vapor/fluent-sqlite-driver) on iOS, macOS, watchOS, and tvOS applications.*

## What is FLite?

FLite is a Swift library that simplifies usage of FluentSQLiteDriver across various Apple platforms. It takes full advantage of Swift's strong type system and modern concurrency features to provide an easy-to-use interface for database management.

## Features
- Powered by FluentSQLiteDriver.
- Simplified access to in-memory and SQLite database functionality.
- Clean and intuitive APIs for database operations.
- Non-blocking asynchronous methods that align with Swift's concurrency model for optimal performance.
- Comprehensive support for database schema migrations.
- Type-safe approach for building and executing database queries.

## Installation

### Swift Package Manager (SPM)

Add the following line to your Package.swift file in the dependencies array:

```swift
dependencies: [
    .package(url: "https://github.com/0xLeif/FLite.git", from: "1.0.0")
]
```

## Usage

Firstly, be sure to import FLite in your file:

```swift
import FLite
```

### Basic Usage

```swift
// Use FLite's shared memory singleton as our FLite database
let flite = FLite.memory

// Prepare a migration for a Todo model
try await flite.prepare(migration: Todo.self)

// Add a model instance to the database
try await flite.add(model: Todo(title: "Hello World", strings: ["hello", "world"]))

// Fetch all instances of our model
let todos = try await flite.all(model: Todo.self)
print(todos)
```

### File Storage

```swift
let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
let fileURL = documentDirectory + "/default.sqlite"

let flite = FLite(configuration: .file(fileURL), loggerLabel: "Custom.FLite")
```

### Batch Operations

```swift
let batchSize: UInt = 3

let todos = (0..<100).map { Todo(title: "Todo #\($0)", strings: []) }
try await flite.add(models: todos, batchSize: batchSize)

let allTodos = try await flite.all(model: Todo.self)
print("Added \(allTodos.count) todos")

try await flite.deleteAll(model: Todo.self, batchSize: batchSize)
```

## Contributing

FLite encourages community involvement and welcomes pull requests from experienced and first-time contributors. For bugs and feature requests, please create an issue.

## License

FLite is released under the MIT License. See `LICENSE` for details.
