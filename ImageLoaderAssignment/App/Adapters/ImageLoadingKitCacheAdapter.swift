import ImageLoadingKit

final class ImageLoadingKitCacheAdapter: ImageCacheClearing {
    private let cacheInvalidator: ImageCacheInvalidating

    init(cacheInvalidator: ImageCacheInvalidating = ImagePipeline.shared) {
        self.cacheInvalidator = cacheInvalidator
    }

    func clearCache() async {
        await cacheInvalidator.invalidateCache()
    }
}
