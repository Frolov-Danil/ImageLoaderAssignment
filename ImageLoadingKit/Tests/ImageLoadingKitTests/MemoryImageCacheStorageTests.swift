import Foundation
import Testing
@testable import ImageLoadingKit

@Suite("Memory image cache storage")
struct MemoryImageCacheStorageTests {
    @Test("Returns stored image while it is valid")
    func returnsStoredImageWhileItIsValid() async throws {
        let storage = MemoryImageCacheStorage()
        let cachedImage = TestValues.cachedImage()

        await storage.store(cachedImage, for: TestValues.url)

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let unwrappedResult = try #require(result)

        #expect(unwrappedResult.data == cachedImage.data)
        #expect(unwrappedResult.metadata.originalURL == cachedImage.metadata.originalURL)
    }

    @Test("Removes expired image on read")
    func removesExpiredImageOnRead() async {
        let storage = MemoryImageCacheStorage()
        let cachedImage = TestValues.cachedImage(expiresAt: TestValues.now)

        await storage.store(cachedImage, for: TestValues.url)

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let secondResult = await storage.cachedImage(for: TestValues.url, now: TestValues.now)

        #expect(result == nil)
        #expect(secondResult == nil)
    }

    @Test("Removes image for URL")
    func removesImageForURL() async {
        let storage = MemoryImageCacheStorage()
        let cachedImage = TestValues.cachedImage()

        await storage.store(cachedImage, for: TestValues.url)
        await storage.removeImage(for: TestValues.url)

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)

        #expect(result == nil)
    }

    @Test("Removes all images")
    func removesAllImages() async {
        let storage = MemoryImageCacheStorage()

        await storage.store(TestValues.cachedImage(), for: TestValues.url)
        await storage.store(TestValues.cachedImage(url: TestValues.anotherURL), for: TestValues.anotherURL)
        await storage.removeAllImages()

        let firstResult = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let secondResult = await storage.cachedImage(for: TestValues.anotherURL, now: TestValues.now)

        #expect(firstResult == nil)
        #expect(secondResult == nil)
    }
}
