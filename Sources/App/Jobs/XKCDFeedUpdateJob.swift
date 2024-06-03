import Queues
import Vapor

struct XKCDFeedUpdateJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        let xkcd = XKCDService(client: context.application.client, logger: context.logger)
        try await context.application.xkcdFeedStorage.getLatestComics(service: xkcd)
    }
}
