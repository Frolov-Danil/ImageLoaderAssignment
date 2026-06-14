import Foundation

/// A two-level cache that keeps frequently used images in memory and persists them on disk.
///
/// The cache reads from memory first because it is the fastest source. On a memory miss,
/// it falls back to disk so cached images remain available after the app is relaunched.
/// When an image is found on disk, the value is written back into memory, making
/// subsequent reads avoid file-system access.
///
/// Store and invalidation operations are mirrored to both cache layers, keeping
/// memory and disk state consistent.
final class CompositeImageCacheStorage: ImageCacheStorageProtocol {
    private let memoryStorage: ImageCacheStorageProtocol
    private let diskStorage: ImageCacheStorageProtocol

    init(memoryStorage: ImageCacheStorageProtocol, diskStorage: ImageCacheStorageProtocol) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
    }

    func cachedImage(for url: URL, now: Date) async -> CachedImage? {
        if let cachedImage = await memoryStorage.cachedImage(for: url, now: now) {
            return cachedImage
        }

        guard let cachedImage = await diskStorage.cachedImage(for: url, now: now) else {
            return nil
        }

        await memoryStorage.store(cachedImage, for: url)
        return cachedImage
    }

    func store(_ cachedImage: CachedImage, for url: URL) async {
        await memoryStorage.store(cachedImage, for: url)
        await diskStorage.store(cachedImage, for: url)
    }

    func removeImage(for url: URL) async {
        await memoryStorage.removeImage(for: url)
        await diskStorage.removeImage(for: url)
    }

    func removeAllImages() async {
        await memoryStorage.removeAllImages()
        await diskStorage.removeAllImages()
    }
}
