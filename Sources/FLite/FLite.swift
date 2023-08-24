import FluentSQLiteDriver
import Fork
import NIO

/**
 `FLite` is a lightweight NoSQL database solution for Swift applications. It leverages the power of FluentSQLiteDriver, SwiftNIO, and Fork creating a streamlined, efficiency-oriented database tool. Primarily, `FLite` encapsulates essential components such as databases, an event loop group, a thread pool, and a logger, providing hands-on control and transparent logging.

 `FLite` class includes both in-memory and SQLite database instances configured with a tailor-made number of threads. With a collection of convenience initializers, the setup is flexible and straightforward. The class also provides a suite of key database operations including but not limited to migration, CRUD operations, and transaction management which are asynchronous and optimized with Swift's concurrency model.

 Effortlessly, with `FLite` developers can set up and manage lightweight and robust databases in their Swift applications.
 */
public class FLite {
    
    // MARK: - Public Static Values
    
    /// A static instance of the FLite database is created in the memory with logger label set to "FLite.memory".
    public static var memory: FLite = FLite(loggerLabel: "FLite.memory")

    // MARK: - Private Values
    
    private var group: EventLoopGroup!
    private var pool: NIOThreadPool!
    private var dbs: Databases!
    private var log: Logger!
    
    internal var db: Database {
        dbs.database(logger: log, on: dbs.eventLoopGroup.next())!
    }
    
    // MARK: - init

    /// Initializer for creating FLite instance with custom configurations.
    public init(
        eventGroup: EventLoopGroup,
        threadPool: NIOThreadPool,
        configuration: DatabaseConfigurationFactory,
        id: DatabaseID,
        logger: Logger
    ) {
        group = eventGroup
        pool = threadPool
        log = logger
        
        pool.start()
        
        dbs = Databases(threadPool: pool, on: group)
        dbs.use(configuration, as: id)
    }

    /// Convenience initializer for creating FLite instance specifying only the number of threads and the database configuration
    public convenience init(
        threads: Int,
        configuration: DatabaseConfigurationFactory,
        logger: Logger
    ) {
        self.init(
            eventGroup: MultiThreadedEventLoopGroup(numberOfThreads: threads),
            threadPool: NIOThreadPool(numberOfThreads: threads),
            configuration: configuration,
            id: .sqlite,
            logger: logger
        )
    }

    /// Convenience initializer for creating FLite instance in memory with a provided logger label. Uses `System.coreCount` as the number of threads.
    public convenience init(
        configuration: SQLiteConfiguration = .init(storage: .memory),
        loggerLabel: String
    ) {
        self.init(
            threads: System.coreCount,
            configuration: .sqlite(configuration),
            logger: Logger(label: loggerLabel)
        )
    }
    
    // MARK: - deinit
    
    deinit {
        destory()
    }

    // MARK: - Public Functions

    /// Shutting down all databases.
    public func shutdown() {
        dbs.shutdown()
    }

    /// Connects to the database and performs operations defined in the provided closure function.
    public func withConnection<Output>(
        closure: @escaping (Database) async throws -> Output
    ) async throws -> Output {
        try await db.withConnection { database in
            try await closure(database)
        }
    }

    /// Create a transation with the database and performs operations defined in the provided closure function within a transaction.
    public func transaction<Output>(
        closure: @escaping (Database) async throws -> Output
    ) async throws -> Output {
        try await db.transaction { database in
            try await closure(database)
        }
    }

    /// Prepare the database for the provided migration.
    public func prepare(migration: Migration) async throws {
        try await prepare(migration: migration).get()
    }

    /// Prepare the database for a model that complies with both Migration and Model protocols.
    public func prepare<T: Migration & Model>(migration: T.Type) async throws {
        try await prepare(migration: migration.init())
    }

    /// Adds a model to the database.
    public func save<T: Model>(model: T) async throws {
        try await model.save(on: db)
    }

    /// Batch add multiple models to the database.
    public func save<T: Model>(models: [T], batchSize: UInt = 10) async throws {
        try await models.asyncBatchedForEach(batch: batchSize) { model in
            try await self.save(model: model)
        }
    }

    /// Deletes a single model from the database.
    public func delete<T: Model>(model: T) async throws {
        try await model.delete(on: db)
    }

    /// Batch delete multiple models from the database.
    public func delete<T: Model>(models: [T], batchSize: UInt = 10) async throws {
        try await models.asyncBatchedForEach(batch: batchSize) { model in
            try await self.delete(model: model)
        }
    }

    /// Update a specific model in the database.
    public func update<T: Model>(model: T) async throws {
        try await model.update(on: db)
    }

    /// Batch update multiple models from the database.
    public func update<T: Model>(models: [T], batchSize: UInt = 10) async throws {
        try await models.asyncBatchedForEach(batch: batchSize) { model in
            try await self.update(model: model)
        }
    }

    /// Deletes all instances of provided model type from the database.
    public func deleteAll<T: Model>(model: T.Type, batchSize: UInt = 10) async throws {
        try await delete(models: all(model: T.self), batchSize: batchSize)
    }

    /// Fetch all the instances of a model.
    public func all<T: Model>(model: T.Type) async throws -> [T] {
        try await db.query(model).all()
    }

    // MARK: - Private Functions

    private func destory() {
        shutdown()
        dbs = nil

        do {
            try pool.syncShutdownGracefully()
        } catch {
            pool.shutdownGracefully { [weak self] in
                self?.log.error("(NIOThreadPool) Shutting Down with Error: \($0.debugDescription)")
            }
        }
        pool = nil

        do {
            try group.syncShutdownGracefully()
        } catch {
            group.shutdownGracefully { [weak self] in
                self?.log.error("(EventLoopGroup) Shutting Down with Error: \($0.debugDescription)")
            }
        }
        group = nil
    }
}
