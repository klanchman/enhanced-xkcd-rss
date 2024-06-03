import Leaf
import Queues
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)

    app.xkcdFeedStorage = XKCDFeedStorage()

    app.logger.notice("Fetching latest XKCD comics")
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

private struct XKCDFeedStorageKey: StorageKey {
    typealias Value = XKCDFeedStorage
}

extension Application {
    fileprivate(set) var xkcdFeedStorage: XKCDFeedStorage {
        get {
            self.storage[XKCDFeedStorageKey.self]!
        }
        set {
            self.storage[XKCDFeedStorageKey.self] = newValue
        }
    }
}
