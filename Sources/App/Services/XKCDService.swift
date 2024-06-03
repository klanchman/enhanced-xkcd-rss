import Foundation
import Vapor

final class XKCDService {
    private static let baseURL = URL(string: "https://xkcd.com")!
    private static let infoPath = "info.0.json"

    private let client: any Client
    private let logger: Logger

    init(client: any Client, logger: Logger) {
        self.client = client
        self.logger = logger
    }

    /// Fetches an xkcd comic by id, or the latest comic if no id is provided.
    ///
    /// - Parameter id: the id of the comic to fetch, or nil to fetch the latest comic
    /// - Returns: an XKCDComic object containing info about the comic
    func getComic(id: Int? = nil) async throws -> XKCDComic {
        let url: URL
        if let id {
            url = Self.baseURL.appending(components: String(id), Self.infoPath)
        } else {
            url = Self.baseURL.appending(component: Self.infoPath)
        }

        let response = try await client.get(URI(string: url.absoluteString))

        guard response.status == .ok else {
            throw XKCDServiceError.unexpectedStatusCode(response.status)
        }

        var comic = try response.content.decode(XKCDComic.self)

        if comic.img.lastPathComponent.contains("_2x.") {
            // Comic image is already the 2x variant, nothing left to do
            return comic
        }

        // Check if a 2x variant of the comic image exists
        guard
            var hiDpiImgComponents = URLComponents(
                url: comic.img,
                resolvingAgainstBaseURL: false
            )
        else {
            logger.warning("Could not convert hi-DPI image URL to URL components")
            return comic
        }
        guard let extIndex = hiDpiImgComponents.path.lastIndex(of: ".") else {
            logger.warning("Could not locate final '.' in image URL")
            return comic
        }
        hiDpiImgComponents.path.insert(contentsOf: "_2x", at: extIndex)
        guard let hiDpiImg = hiDpiImgComponents.url else {
            logger.warning("Could not convert final hi-DPI image URL components to URL")
            return comic
        }

        if try await imageURLExists(hiDpiImg) {
            comic.img = hiDpiImg
        }

        return comic
    }

    private func imageURLExists(_ url: URL) async throws -> Bool {
        let response = try await client.send(.HEAD, to: URI(string: url.absoluteString))
        return (200..<300).contains(response.status.code)
    }
}

private enum XKCDServiceError: AbortError {
    case unexpectedStatusCode(HTTPResponseStatus)

    var status: HTTPResponseStatus {
        switch self {
        case .unexpectedStatusCode:
            .badGateway
        }
    }
}
