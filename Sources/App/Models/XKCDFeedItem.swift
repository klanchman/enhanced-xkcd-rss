import Foundation

struct XKCDFeedItem: Encodable {
    let title: String
    let link: String
    let description: Description
    let publishDate: Date
    let guid: String
}

extension XKCDFeedItem {
    struct Description: Encodable {
        let explainURL: String
        let imageURL: String
        let mobileURL: String

        let altText: String?
        let hasExtraParts: Bool
        let link: String?
        let news: String?
    }
}
