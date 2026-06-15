import Testing
import UIKit
@testable import ImageLoadingKit

@Suite("Image pipeline")
struct ImagePipelineTests {
    @Test("Returns cached image without downloading")
    func returnsCachedImageWithoutDownloading() async throws {
        let cachedImage = TestValues.cachedImage(data: TestValues.pngData)
        let cache = ImageCacheStorageSpy(cachedImages: [TestValues.url: cachedImage])
        let downloader = ImageDownloaderSpy(data: TestValues.invalidImageData)
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)

        let image = try await pipeline.image(for: TestValues.url)

        #expect(image.size.width > 0)
        #expect(await downloader.requestCount() == 0)
    }

    @Test("Downloads and stores image on cache miss")
    func downloadsAndStoresImageOnCacheMiss() async throws {
        let cache = ImageCacheStorageSpy()
        let downloader = ImageDownloaderSpy(data: TestValues.pngData)
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)

        let image = try await pipeline.image(for: TestValues.url)
        let storedImage = await cache.storedImage(for: TestValues.url)
        let unwrappedStoredImage = try #require(storedImage)

        #expect(image.size.width > 0)
        #expect(await downloader.requestCount() == 1)
        #expect(await cache.storeCallCount() == 1)
        #expect(unwrappedStoredImage.metadata.originalURL == TestValues.url)

        let cacheLifetime = unwrappedStoredImage.metadata.expiresAt
            .timeIntervalSince(unwrappedStoredImage.metadata.cachedAt)
        #expect(cacheLifetime == 14_400)
    }

    @Test("Throws invalid image data when downloaded data cannot be decoded")
    func throwsInvalidImageDataWhenDownloadedDataCannotBeDecoded() async throws {
        let cache = ImageCacheStorageSpy()
        let downloader = ImageDownloaderSpy(data: TestValues.invalidImageData)
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)
        var didThrowInvalidImageData = false

        do {
            _ = try await pipeline.image(for: TestValues.url)
        } catch ImageLoadingError.invalidImageData {
            didThrowInvalidImageData = true
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(didThrowInvalidImageData)
    }

    @Test("Shares concurrent download for same URL")
    func sharesConcurrentDownloadForSameURL() async throws {
        let cache = ImageCacheStorageSpy()
        let downloader = ImageDownloaderSpy(
            data: TestValues.pngData,
            delayNanoseconds: 100_000_000
        )
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)

        async let firstImage = pipeline.image(for: TestValues.url)
        async let secondImage = pipeline.image(for: TestValues.url)

        _ = try await (firstImage, secondImage)

        #expect(await downloader.requestCount() == 1)
        #expect(await cache.storeCallCount() == 1)
    }

    @Test("Invalidation removes all cached images")
    func invalidationRemovesAllCachedImages() async {
        let cache = ImageCacheStorageSpy()
        let downloader = ImageDownloaderSpy(data: TestValues.pngData)
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)

        await pipeline.invalidateCache()

        #expect(await cache.removeAllImagesCallCount() == 1)
    }

    @Test("Invalidation removes cached image for URL")
    func invalidationRemovesCachedImageForURL() async {
        let cache = ImageCacheStorageSpy()
        let downloader = ImageDownloaderSpy(data: TestValues.pngData)
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)

        await pipeline.invalidateCache(for: TestValues.url)

        #expect(await cache.removeImageCallCount() == 1)
        #expect(await cache.removedURLs() == [TestValues.url])
    }
}
