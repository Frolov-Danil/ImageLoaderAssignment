import Foundation

struct CachedImage: Codable, Sendable {
    struct Metadata: Codable, Sendable {
        let originalURL: URL
        let cachedAt: Date
        let expiresAt: Date

        func isValid(at date: Date) -> Bool {
            expiresAt > date
        }
    }

    let data: Data
    let metadata: Metadata

    func isValid(at date: Date) -> Bool {
        metadata.isValid(at: date)
    }
}
