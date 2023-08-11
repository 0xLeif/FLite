import FluentSQLiteDriver

extension FLite: QueryBuildable {
    public func query<T: Model>(model: T.Type) -> QueryBuilder<T> {
        db.query(model)
    }

    public func execute<T: Model>(
        query queryBuilder: (QueryBuildable) -> QueryBuilder<T>
    ) async throws -> DatabaseOutput {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let query = queryBuilder(self).query

                try db.execute(query: query) { output in
                    continuation.resume(returning: output)
                }
                .wait()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
