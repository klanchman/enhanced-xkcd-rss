import Vapor

struct AppConfig {
    let site: Site

    init() throws {
        site = try Site()
    }
}

extension AppConfig {
    struct Site {
        let baseURL: String

        init() throws {
            baseURL = try Environment.ensure("BASE_URL")
        }
    }
}
