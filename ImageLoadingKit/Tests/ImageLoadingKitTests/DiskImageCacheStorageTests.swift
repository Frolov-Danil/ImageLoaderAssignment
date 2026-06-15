import Foundation
import Testing
@testable import ImageLoadingKit

@Suite("Disk image cache storage")
struct DiskImageCacheStorageTests {
    @Test("Returns stored image from disk")
    func returnsStoredImageFromDisk() async throws {
        let directoryURL = try TemporaryDirectory.make()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let storage = DiskImageCacheStorage(directoryURL: directoryURL)
        let cachedImage = TestValues.cachedImage()

        await storage.store(cachedImage, for: TestValues.url)

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let unwrappedResult = try #require(result)

        #expect(unwrappedResult.data == cachedImage.data)
        #expect(unwrappedResult.metadata.originalURL == cachedImage.metadata.originalURL)
    }

    @Test("Persists cached image between storage instances")
    func persistsCachedImageBetweenStorageInstances() async throws {
        let directoryURL = try TemporaryDirectory.make()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let firstStorage = DiskImageCacheStorage(directoryURL: directoryURL)
        let secondStorage = DiskImageCacheStorage(directoryURL: directoryURL)
        let cachedImage = TestValues.cachedImage()

        await firstStorage.store(cachedImage, for: TestValues.url)

        let result = await secondStorage.cachedImage(for: TestValues.url, now: TestValues.now)
        let unwrappedResult = try #require(result)

        #expect(unwrappedResult.data == cachedImage.data)
        #expect(unwrappedResult.metadata.cachedAt == cachedImage.metadata.cachedAt)
    }

    @Test("Does not return expired image")
    func doesNotReturnExpiredImage() async throws {
        let directoryURL = try TemporaryDirectory.make()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let storage = DiskImageCacheStorage(directoryURL: directoryURL)
        let cachedImage = TestValues.cachedImage(expiresAt: TestValues.now)

        await storage.store(cachedImage, for: TestValues.url)

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)

        #expect(result == nil)
    }

    @Test("Removes image for URL")
    func removesImageForURL() async throws {
        let directoryURL = try TemporaryDirectory.make()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let storage = DiskImageCacheStorage(directoryURL: directoryURL)

        await storage.store(TestValues.cachedImage(), for: TestValues.url)
        await storage.removeImage(for: TestValues.url)

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)

        #expect(result == nil)
    }

    @Test("Removes all images")
    func removesAllImages() async throws {
        let directoryURL = try TemporaryDirectory.make()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let storage = DiskImageCacheStorage(directoryURL: directoryURL)

        await storage.store(TestValues.cachedImage(), for: TestValues.url)
        await storage.store(TestValues.cachedImage(url: TestValues.anotherURL), for: TestValues.anotherURL)
        await storage.removeAllImages()

        let firstResult = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let secondResult = await storage.cachedImage(for: TestValues.anotherURL, now: TestValues.now)

        #expect(firstResult == nil)
        #expect(secondResult == nil)
    }
}
