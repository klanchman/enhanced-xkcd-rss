actor XKCDFeedStorage {
    private(set) var comics = [XKCDComic]()

    func getLatestComics(count: Int = 5, service: XKCDService) async throws {
        var newComics = [XKCDComic]()
        let latestComic = try await service.getComic()

        newComics.append(latestComic)

        for id in latestComic.num - count + 1..<latestComic.num {
            newComics.insert(try await service.getComic(id: id), at: 1)
        }

        comics = newComics
    }
}
