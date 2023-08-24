import Foundation
import FluentSQLiteDriver

internal final class Todo: Model {
    init() { }
    
    static let schema: String = "todos"
    
    /// The unique identifier for this `Todo`.
    @ID(key: .id)
    var id: UUID?

    /// A title describing what this `Todo` entails.
    @Field(key: "title")
    var title: String
    
    @Field(key: "someList")
    var someList: [String]

    /// Creates a new `Todo`.
    init(id: UUID? = nil, title: String, strings: [String]) {
        self.id = id
        self.title = title
        self.someList = strings
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Todo.schema)
            .id()
            .field("title", .string, .required)
            .field("someList", .array(of: .string), .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Todo.schema).delete()
    }
}

extension Todo: CustomStringConvertible {
    var description: String {
        return """
        Todo id: \(String(describing: id))
            title: \(title)
            someList: \(someList)
        """
    }
}
