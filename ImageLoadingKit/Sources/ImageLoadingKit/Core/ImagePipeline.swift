import UIKit

public protocol ImageLoading: ImageCacheInvalidating {
    func image(for url: URL) async throws -> UIImage
}

public protocol ImageCacheInvalidating: AnyObject {
    func invalidateCache() async
    func invalidateCache(for url: URL) async
}

public actor ImagePipeline: ImageLoading {
    public static let shared = ImagePipeline()

    private let downloader: ImageDownloading
    private let cache: ImageCache
    private let cacheExpirationInterval: TimeInterval
    private let dateProvider: @Sendable () -> Date

    private var inFlightTasks: [URL: InFlightImageTask] = [:]

    public init(cacheExpirationInterval: TimeInterval = 14_400) {
        self.init(
            downloader: URLSessionImageDownloader(),
            cache: CompositeImageCache(
                primaryCache: MemoryImageCache(),
                secondaryCache: DiskImageCache()
            ),
            cacheExpirationInterval: cacheExpirationInterval
        )
    }

    init(
        downloader: ImageDownloading,
        cache: ImageCache,
        cacheExpirationInterval: TimeInterval = 14_400,
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.downloader = downloader
        self.cache = cache
        self.cacheExpirationInterval = cacheExpirationInterval
        self.dateProvider = dateProvider
    }

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

    public func invalidateCache() async {
        inFlightTasks.values.forEach { $0.task.cancel() }
        inFlightTasks.removeAll()
        await cache.removeAllImages()
    }

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
            let metadata = CachedImageMetadata(
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
