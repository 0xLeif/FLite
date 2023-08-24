import XCTest
import FluentSQLiteDriver
import Fork
@testable import FLite

final class FLiteTests: XCTestCase {
    override func tearDown() {
        FLite.memory.shutdown()
    }
    
    func testExample() async throws {
        try await FLite.memory.prepare(migration: Todo.self)

        try await FLite.memory.save(model: Todo(title: "Hello World", strings: ["hello", "world"]))

        let values = try await FLite.memory.all(model: Todo.self)

        XCTAssertFalse(values.isEmpty)
    }

    func testCustomFLite() async throws {
        let flite = FLite(
            threads: 30,
            configuration: .sqlite(.memory, maxConnectionsPerEventLoop: 30),
            logger: Logger(label: "Custom.FLITE")
        )

        try await flite.prepare(migration: Todo.self)

        try await flite.save(model: Todo(title: "Hello World", strings: ["hello", "world"]))

        let values = try await flite.all(model: Todo.self)

        XCTAssertFalse(values.isEmpty)
    }
    
    func testTodoArray() async throws {
        let arrayCount: Int = 1000

        let totalValues = arrayCount * 3

        let flite = FLite(configuration: .memory, loggerLabel: "test.flite")

        try? await flite.prepare(migration: Todo.self)

        let mockValuesArray = (0 ..< arrayCount).map { _ in Todo(title: "Todo #\(Int.random(in: 0 ... 10000))", strings: []) }
        let mockValuesArray2 = (0 ..< arrayCount).map { _ in Todo(title: "Todo #\(Int.random(in: 0 ... 10000))", strings: []) }
        let mockValuesArray3 = (0 ..< arrayCount).map { _ in Todo(title: "Todo #\(Int.random(in: 0 ... 10000))", strings: []) }

        try await [mockValuesArray, mockValuesArray2, mockValuesArray3].asyncForEach { models in
            try await flite.save(models: models)
        }

        let values = try await flite.all(model: Todo.self)

        XCTAssertEqual(values.count, totalValues)

        try await flite.deleteAll(model: Todo.self)

        let emptyValues = try await flite.all(model: Todo.self)

        XCTAssert(emptyValues.isEmpty)
    }
}
