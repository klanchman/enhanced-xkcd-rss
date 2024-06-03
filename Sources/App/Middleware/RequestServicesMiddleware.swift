import Vapor

struct RequestServicesMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: any Responder) -> EventLoopFuture<Response> {
        request.xkcd = XKCDService(client: request.client, logger: request.logger)
        return next.respond(to: request)
    }
}

struct XKCDServiceKey: StorageKey {
    typealias Value = XKCDService
}

extension Request {
    fileprivate(set) var xkcd: XKCDService? {
        get {
            self.storage[XKCDServiceKey.self]
        }
        set {
            self.storage[XKCDServiceKey.self] = newValue
        }
    }
}
