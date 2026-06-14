import ImageLoadingKit

final class ImageLoadingKitCacheAdapter: ImageCacheClearingProtocol {
    private let imagePipeline: ImagePipeline

    init(imagePipeline: ImagePipeline = ImagePipeline.shared) {
        self.imagePipeline = imagePipeline
    }

    func clearCache() async {
        await imagePipeline.invalidateCache()
    }
}
