import UIKit

actor ImagePipeline {
    private struct InFlightImageTask {
        let id = UUID()
        let task: Task<UIImage, Error>
    }

    static let shared = ImagePipeline()

    private let downloader: ImageDownloadingProtocol
    private let cache: ImageCacheStorageProtocol

    private var inFlightTasks: [URL: InFlightImageTask] = [:]

    private init() {
        self.downloader = URLSessionImageDownloader()
        self.cache = CompositeImageCacheStorage(
            memoryStorage: MemoryImageCacheStorage(),
            diskStorage: DiskImageCacheStorage()
        )
    }

    init(
        downloader: ImageDownloadingProtocol,
        cache: ImageCacheStorageProtocol
    ) {
        self.downloader = downloader
        self.cache = cache
    }

    func image(for url: URL) async throws -> UIImage {
        let now = Date()

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

    func invalidateCache() async {
        inFlightTasks.values.forEach { $0.task.cancel() }
        inFlightTasks.removeAll()
        await cache.removeAllImages()
    }

    func invalidateCache(for url: URL) async {
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

            let cachedAt = Date()
            let metadata = CachedImage.Metadata(
                originalURL: url,
                cachedAt: cachedAt,
                expiresAt: cachedAt.addingTimeInterval(Constants.cacheExpirationInterval)
            )
            let cachedImage = CachedImage(data: data, metadata: metadata)

            await cache.store(cachedImage, for: url)
            return image
        }
    }
}

// MARK: - Constants

private extension ImagePipeline {
    enum Constants {
        static let cacheExpirationInterval: TimeInterval = 4 * 60 * 60
    }
}
