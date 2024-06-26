import Leaf
import Queues
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)

    app.config = try AppConfig()
    app.xkcdFeedStorage = XKCDFeedStorage()

    app.logger.notice("Fetching latest xkcd comics")
    try? await app.xkcdFeedStorage.getLatestComics(
        service: XKCDService(client: app.client, logger: app.logger)
    )

    // register routes
    try routes(app)

    for minute in stride(from: 5, through: 60, by: 10) {
        app.queues.schedule(XKCDFeedUpdateJob()).hourly().at(.init(integerLiteral: minute))
    }

    try app.queues.startScheduledJobs()
}

private struct AppConfigKey: StorageKey {
    typealias Value = AppConfig
}

private struct XKCDFeedStorageKey: StorageKey {
    typealias Value = XKCDFeedStorage
}

extension Application {
    /// A service containing configuration for this app.
    fileprivate(set) var config: AppConfig {
        get {
            // !: This is guaranteed to be set during the configure method above
            self.storage[AppConfigKey.self]!
        }
        set {
            self.storage[AppConfigKey.self] = newValue
        }
    }

    fileprivate(set) var xkcdFeedStorage: XKCDFeedStorage {
        get {
            // !: This is guaranteed to be set during the configure method above
            self.storage[XKCDFeedStorageKey.self]!
        }
        set {
            self.storage[XKCDFeedStorageKey.self] = newValue
        }
    }
}
