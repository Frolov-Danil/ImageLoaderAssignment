import Foundation

actor MemoryImageCacheStorage: ImageCacheStorageProtocol {
    private let cache = NSCache<NSURL, CachedImageBox>()

    func cachedImage(for url: URL, now: Date) async -> CachedImage? {
        guard let cachedImage = cache.object(forKey: url as NSURL)?.cachedImage else {
            return nil
        }

        guard cachedImage.isValid(at: now) else {
            await removeImage(for: url)
            return nil
        }

        return cachedImage
    }

    func store(_ cachedImage: CachedImage, for url: URL) async {
        cache.setObject(CachedImageBox(cachedImage), forKey: url as NSURL)
    }

    func removeImage(for url: URL) async {
        cache.removeObject(forKey: url as NSURL)
    }

    func removeAllImages() async {
        cache.removeAllObjects()
    }
}

private final class CachedImageBox {
    let cachedImage: CachedImage

    init(_ cachedImage: CachedImage) {
        self.cachedImage = cachedImage
    }
}
