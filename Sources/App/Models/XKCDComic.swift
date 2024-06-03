import Vapor

struct XKCDComic: Codable {
    let num: Int
    let title: String
    let safeTitle: String
    var img: URL
    let alt: String?

    let month: String
    let day: String
    let year: String

    let link: URL?
    let news: String?
    let hasExtraParts: Bool

    enum CodingKeys: String, CodingKey {
        case month, day, year, num, title, img, alt, link, news
        case safeTitle = "safe_title"
        case hasExtraParts = "extra_parts"
    }
}

extension XKCDComic {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        num = try container.decode(Int.self, forKey: .num)
        title = try container.decode(String.self, forKey: .title)
        safeTitle = try container.decode(String.self, forKey: .safeTitle)
        img = try container.decode(URL.self, forKey: .img)
        alt = try container.decodeIfPresent(String.self, forKey: .alt)

        month = try container.decode(String.self, forKey: .month)
        day = try container.decode(String.self, forKey: .day)
        year = try container.decode(String.self, forKey: .year)

        let rawLink = try container.decodeIfPresent(String.self, forKey: .link)
        if let rawLink, !rawLink.isEmpty {
            guard let link = URL(string: rawLink) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .link,
                    in: container,
                    debugDescription: "Invalid URL string"
                )
            }

            self.link = link
        } else {
            link = nil
        }

        let rawNews = try container.decodeIfPresent(String.self, forKey: .news)
        if let rawNews, !rawNews.isEmpty {
            self.news = rawNews
        } else {
            news = nil
        }

        hasExtraParts = container.contains(.hasExtraParts)
    }
}
