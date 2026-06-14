import Foundation

protocol ImageCache: AnyObject {
    func cachedImage(for url: URL, now: Date) async -> CachedImage?
    func store(_ cachedImage: CachedImage, for url: URL) async
    func removeImage(for url: URL) async
    func removeAllImages() async
}

struct CachedImage: Codable, Sendable {
    let data: Data
    let metadata: CachedImageMetadata

    func isValid(at date: Date) -> Bool {
        metadata.isValid(at: date)
    }
}

struct CachedImageMetadata: Codable, Sendable {
    let originalURL: URL
    let cachedAt: Date
    let expiresAt: Date

    func isValid(at date: Date) -> Bool {
        expiresAt > date
    }
}
