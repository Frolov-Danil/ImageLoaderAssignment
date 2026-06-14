import Foundation

protocol ImageCacheProtocol: AnyObject {
    func cachedImage(for url: URL, now: Date) async -> CachedImage?
    func store(_ cachedImage: CachedImage, for url: URL) async
    func removeImage(for url: URL) async
    func removeAllImages() async
}
