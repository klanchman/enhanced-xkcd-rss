import Vapor

private let feedItems = [
    XKCDFeedItem(
        title: "Pub Trivia",
        link: "https://xkcd.com/2922",
        description: .init(
            explainURL: "https://www.explainxkcd.com/wiki/index.php/2922",
            imageURL: "https://imgs.xkcd.com/comics/pub_trivia_2x.png",
            mobileURL: "https://m.xkcd.com/2922",
            altText:
                "Bonus question: Where is London located? (a) The British Isles (b) Great Britain and Northern Ireland (c) The UK (d) Europe (or 'the EU') (e) Greater London",
            hasExtraParts: false,
            link: nil,
            news: nil
        ),
        publishDate: Date(),
        guid: "GUID3"
    )
]

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        try await req.view.render(
            "index",
            IndexContext(title: "xkcd.com Enhanced Feed", feedTitle: "xkcd.com Enhanced")
        )
    }

    app.get("index.xml") { req async throws -> Response in
        try await req.view.render(
            "rss",
            RSSLeafContext(items: feedItems)
        ).encodeRSSResponse(for: req)
    }

    app.get("feed.json") { req async throws -> Response in
        var items = [JSONFeed.Item]()
        for item in feedItems {
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
