import FluentSQLiteDriver

/// `QueryBuildable` protocol provides an abstract structure for building and executing database queries.
public protocol QueryBuildable {
    /// Constructs a `QueryBuilder` for the specified model type. This allows for building complex queries in a type-safe, easy-to-understand manner.
    ///
    /// - Parameter model: The `Model` type for which the query needs to be built.
    ///
    /// - Returns: An instance of `QueryBuilder` set up for the specified `Model` type. This `QueryBuilder` can be further configured to define specific database operations.
    func query<T: Model>(model: T.Type) -> QueryBuilder<T>

    /// Executes a specified database operation encapsulated by a `QueryBuilder`. This method performs the query represented by the `QueryBuilder` and returns the result of the database operation. This provides a seamless way to run database operations asynchronously without blocking.
    ///
    /// - Parameter queryBuilder: A closure that takes an instance conforming to `QueryBuildable` and returns a fully constructed `QueryBuilder`. The `QueryBuilder` instance inside this closure defines the specific database operation to be executed.
    ///
    /// - Throws: Can throw an error if the query execution doesn't succeed, for example, because of erroneous query parameters or connectivity issues.
    ///
    /// - Returns: The result of the executed database query as a `DatabaseOutput` instance. This `DatabaseOutput` can be used to further process or retrieve the data resulting from the query operation.
    func execute<T: Model>(
        query queryBuilder: (QueryBuildable) -> QueryBuilder<T>
    ) async throws -> DatabaseOutput
}
