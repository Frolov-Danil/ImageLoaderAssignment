struct ClearImageCacheUseCase {
    private let imageCache: ImageCacheClearingProtocol

    init(imageCache: ImageCacheClearingProtocol) {
        self.imageCache = imageCache
    }

    func execute() async {
        await imageCache.clearCache()
    }
}
