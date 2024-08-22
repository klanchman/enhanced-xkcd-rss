actor XKCDFeedStorage {
    private(set) var comics = [XKCDComic]()

    func getLatestComics(count: Int = 5, service: XKCDService) async throws {
        var newComics = [XKCDComic]()
        let latestComic = try await service.getComic()

        if comics.contains(where: { $0.num == latestComic.num }) && comics.count == count {
            return
        }

        newComics.append(latestComic)

        for id in latestComic.num - count + 1..<latestComic.num {
            if let existing = comics.first(where: { $0.num == id }) {
                newComics.insert(existing, at: 1)
            } else {
                newComics.insert(try await service.getComic(id: id), at: 1)
            }
        }

        comics = newComics
    }
}
