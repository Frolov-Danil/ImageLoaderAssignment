import UIKit

/// An actor that downloads remote images and coordinates memory and disk caching.
///
/// `ImagePipeline` is the central entry point for `ImageLoadingKit`. It checks
/// the cache before starting a network request, stores successfully downloaded
/// images in both cache layers, and shares in-flight requests for the same URL.
///
/// Use ``shared`` for the default pipeline used by the UIKit and SwiftUI views.
public actor ImagePipeline {
    /// The shared image pipeline used by the default UIKit and SwiftUI views.
    ///
    /// The shared pipeline uses a memory cache, a disk cache, and the default
    /// cache expiration interval.
    public static let shared = ImagePipeline()

    /// The default amount of time a cached image remains valid.
    ///
    /// Cached images are valid for 4 hours by default.
    public static let defaultCacheExpirationInterval: TimeInterval = 4 * 60 * 60

    private let downloader: ImageDownloadingProtocol
    private let cache: ImageCacheProtocol
    private let cacheExpirationInterval: TimeInterval
    private let dateProvider: @Sendable () -> Date

    private var inFlightTasks: [URL: InFlightImageTask] = [:]

    init(cacheExpirationInterval: TimeInterval = ImagePipeline.defaultCacheExpirationInterval) {
        self.init(
            downloader: URLSessionImageDownloader(),
            cache: CompositeImageCache(
                memoryCache: MemoryImageCache(),
                diskCache: DiskImageCache()
            ),
            cacheExpirationInterval: cacheExpirationInterval
        )
    }

    init(
        downloader: ImageDownloadingProtocol,
        cache: ImageCacheProtocol,
        cacheExpirationInterval: TimeInterval = ImagePipeline.defaultCacheExpirationInterval,
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.downloader = downloader
        self.cache = cache
        self.cacheExpirationInterval = cacheExpirationInterval
        self.dateProvider = dateProvider
    }

    /// Returns an image for the specified URL.
    ///
    /// The pipeline first checks the memory and disk caches. If no valid cached
    /// image exists, it downloads the image, stores it in the cache, and returns
    /// the decoded `UIImage`.
    ///
    /// Concurrent calls for the same URL share a single in-flight download task.
    ///
    /// - Parameter url: The remote image URL.
    /// - Returns: The cached or downloaded image.
    /// - Throws: `ImageLoadingError.invalidResponse` when the server response is
    ///   not successful, `ImageLoadingError.invalidImageData` when the downloaded
    ///   data cannot be decoded as an image, or a `URLSession` error.
    public func image(for url: URL) async throws -> UIImage {
        let now = dateProvider()

        if let cachedImage = await cache.cachedImage(for: url, now: now),
           let image = UIImage(data: cachedImage.data) {
            return image
        }

        await cache.removeImage(for: url)

        if let inFlightTask = inFlightTasks[url] {
            return try await inFlightTask.task.value
        }

        let inFlightTask = InFlightImageTask(task: makeDownloadTask(for: url))
        inFlightTasks[url] = inFlightTask

        defer {
            if inFlightTasks[url]?.id == inFlightTask.id {
                inFlightTasks[url] = nil
            }
        }

        return try await inFlightTask.task.value
    }

    /// Removes all cached images and cancels all in-flight image requests.
    ///
    /// This method clears both memory and disk cache layers.
    public func invalidateCache() async {
        inFlightTasks.values.forEach { $0.task.cancel() }
        inFlightTasks.removeAll()
        await cache.removeAllImages()
    }

    /// Removes the cached image and cancels the in-flight request for a URL.
    ///
    /// - Parameter url: The URL whose cached image should be removed.
    public func invalidateCache(for url: URL) async {
        inFlightTasks[url]?.task.cancel()
        inFlightTasks[url] = nil
        await cache.removeImage(for: url)
    }
}

// MARK: - Private

private extension ImagePipeline {
    func makeDownloadTask(for url: URL) -> Task<UIImage, Error> {
        Task {
            let data = try await downloader.data(from: url)

            guard let image = UIImage(data: data) else {
                throw ImageLoadingError.invalidImageData
            }

            let cachedAt = dateProvider()
            let metadata = CachedImage.Metadata(
                originalURL: url,
                cachedAt: cachedAt,
                expiresAt: cachedAt.addingTimeInterval(cacheExpirationInterval)
            )
            let cachedImage = CachedImage(data: data, metadata: metadata)

            await cache.store(cachedImage, for: url)
            return image
        }
    }
}

private struct InFlightImageTask {
    let id = UUID()
    let task: Task<UIImage, Error>
}
