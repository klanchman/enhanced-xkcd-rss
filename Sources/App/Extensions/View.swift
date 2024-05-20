import Vapor

extension View {
    func encodeRSSResponse(for request: Request) async throws -> Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/rss+xml")
        return try await encodeResponse(status: .ok, headers: headers, for: request)
    }
}
