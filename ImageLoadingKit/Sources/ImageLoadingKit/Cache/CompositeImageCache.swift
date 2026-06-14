import Foundation

final class CompositeImageCache: ImageCache {
    private let primaryCache: ImageCache
    private let secondaryCache: ImageCache

    init(primaryCache: ImageCache, secondaryCache: ImageCache) {
        self.primaryCache = primaryCache
        self.secondaryCache = secondaryCache
    }

    func cachedImage(for url: URL, now: Date) async -> CachedImage? {
        if let cachedImage = await primaryCache.cachedImage(for: url, now: now) {
            return cachedImage
        }

        guard let cachedImage = await secondaryCache.cachedImage(for: url, now: now) else {
            return nil
        }

        await primaryCache.store(cachedImage, for: url)
        return cachedImage
    }

    func store(_ cachedImage: CachedImage, for url: URL) async {
        await primaryCache.store(cachedImage, for: url)
        await secondaryCache.store(cachedImage, for: url)
    }

    func removeImage(for url: URL) async {
        await primaryCache.removeImage(for: url)
        await secondaryCache.removeImage(for: url)
    }

    func removeAllImages() async {
        await primaryCache.removeAllImages()
        await secondaryCache.removeAllImages()
    }
}
