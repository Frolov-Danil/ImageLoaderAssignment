protocol ImageCacheClearing {
    func clearCache() async
}

struct ClearImageCacheUseCase {
    private let imageCache: ImageCacheClearing

    init(imageCache: ImageCacheClearing) {
        self.imageCache = imageCache
    }

    func execute() async {
        await imageCache.clearCache()
    }
}
