import Vapor

struct JSONFeed: Content {
    let version = "https://jsonfeed.org/version/1.1"
    let title: String
    let homePageURL: String
    let feedURL: String?
    let description: String?
    let language: String?
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case version, title, description, language, items
        case homePageURL = "home_page_url"
        case feedURL = "feed_url"
    }

    struct Item: Content {
        let id: String
        let contentHTML: String
        let url: String?
        let title: String?
        let summary: String?
        let image: String?
        let datePublished: Date?

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case id, url, title, summary, image
            case contentHTML = "content_html"
            case datePublished = "date_published"
        }
    }
}
