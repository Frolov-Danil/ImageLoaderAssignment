import UIKit

public protocol ImageLoading: ImageCacheInvalidating {
    func image(for url: URL) async throws -> UIImage
}

public protocol ImageCacheInvalidating: AnyObject {
    func invalidateCache() async
    func invalidateCache(for url: URL) async
}

public final class ImagePipeline: ImageLoading {
    public static let shared = ImagePipeline()

    private let downloader: ImageDownloading
    private let cache: ImageCache

    init(
        downloader: ImageDownloading = URLSessionImageDownloader(),
        cache: ImageCache = CompositeImageCache(
            primaryCache: MemoryImageCache(),
            secondaryCache: DiskImageCache()
        )
    ) {
        self.downloader = downloader
        self.cache = cache
    }

    public func image(for url: URL) async throws -> UIImage {
        if let cachedData = await cache.data(for: url),
           let cachedImage = UIImage(data: cachedData) {
            return cachedImage
        }

        let data = try await downloader.data(from: url)

        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidImageData
        }

        await cache.store(data, for: url)
        return image
    }

    public func invalidateCache() async {
        await cache.removeAllData()
    }

    public func invalidateCache(for url: URL) async {
        await cache.removeData(for: url)
    }
}
