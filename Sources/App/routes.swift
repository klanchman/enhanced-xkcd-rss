import Vapor

func routes(_ app: Application) throws {
    app.group(RequestServicesMiddleware()) { group in
        group.get { req async throws -> View in
            try await req.view.render(
                "index",
                IndexContext(title: "xkcd.com Enhanced Feed", feedTitle: "xkcd.com Enhanced")
            )
        }

        group.get("index.xml") { req async throws -> Response in
            try await req.view.render(
                "rss",
                RSSLeafContext(items: try await getFeedItems(for: req))
            ).encodeRSSResponse(for: req)
        }

        group.get("feed.json") { req async throws -> Response in
            var items = [JSONFeed.Item]()
            for item in try await getFeedItems(for: req) {
                items.append(try await .init(from: item, request: req))
            }

            let response = try await JSONFeed(
                title: "xkcd.com Enhanced",
                homePageURL: "https://xkcd.com",
                feedURL: nil,  // FIXME: Config value?
                description: "A webcomic of romance, sarcasm, math, and language.",
                language: "en",
                items: items
            ).encodeResponse(for: req)

            response.headers.replaceOrAdd(name: .contentType, value: "application/feed+json")
            return response
        }

        // MARK: Debug routes
        #if DEBUG
        group.get("comic") { req async throws -> XKCDComic in
            try await req.xkcd!.getComic(id: nil)
        }

        group.get("comic", ":comicId") { req async throws -> XKCDComic in
            try await req.xkcd!.getComic(
                id: req.parameters.get("comicId")
            )
        }
        #endif
    }
}

private func getFeedItems(for req: Request) async throws -> [XKCDFeedItem] {
    // FIXME: Implement for real
    let comic = try await req.xkcd!.getComic(id: 2914)

    return [
        XKCDFeedItem(
            title: comic.safeTitle,
            link: "https://xkcd.com/\(comic.num)",
            description: XKCDFeedItem.Description(
                explainURL: "https://www.explainxkcd.com/wiki/index.php/\(comic.num)",
                imageURL: comic.img.absoluteString,
                mobileURL: "https://m.xkcd.com/\(comic.num)",
                altText: comic.alt,
                hasExtraParts: comic.hasExtraParts,
                link: comic.link?.absoluteString,
                news: comic.news
            ),
            publishDate: Date(),
            guid: "\(comic.num)"
        )
    ]
}

extension JSONFeed.Item {
    init(from item: XKCDFeedItem, request: Request) async throws {
        id = item.guid
        let viewBytes = try await request.view.render("description", item.description).data
            .readableBytesView
        contentHTML = String(decoding: viewBytes, as: UTF8.self)
        url = item.link
        title = item.title
        summary = nil
        image = item.description.imageURL
    }
}

extension XKCDComic: Content {}
