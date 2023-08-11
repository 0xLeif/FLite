import FluentSQLiteDriver
import NIO

extension FLite {
    /// Prepare the database for specific migration and return an `EventLoopFuture` that completes when the operation is done.
    public func prepare(migration: Migration) -> EventLoopFuture<Void> {
        migration.prepare(on: db)
    }

    /// Prepare the database for a model that complies with both Migration and Model protocols (initializing the model before the preparation).
    /// Returns an `EventLoopFuture` that completes when the operation is done.
    public func prepare<T: Migration & Model>(migration: T.Type) -> EventLoopFuture<Void> {
        migration.init().prepare(on: db)
    }

    /// Add a model to the database. This function returns an `EventLoopFuture` that completes when the Save operation is done.
    public func add<T: Model>(model: T) -> EventLoopFuture<Void> {
        model.save(on: db)
    }

    /// Deletes a model from the database. This function returns an `EventLoopFuture` that completes when the Delete operation is done.
    public func delete<T: Model>(model: T) -> EventLoopFuture<Void> {
        model.delete(on: db)
    }

    /// Update a specific model in the database. This function returns an `EventLoopFuture` that completes when the Update operation is done.
    public func update<T: Model>(model: T) -> EventLoopFuture<Void> {
        model.update(on: db)
    }

    /// Fetch all the instances of a model from the database. The result of the operation is wrapped in an `EventLoopFuture`.
    public func all<T: Model>(model: T.Type) -> EventLoopFuture<[T]> {
        db.query(model).all()
    }
}
