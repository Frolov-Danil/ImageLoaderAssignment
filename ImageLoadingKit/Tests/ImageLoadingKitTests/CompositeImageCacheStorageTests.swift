import Foundation
import Testing
@testable import ImageLoadingKit

@Suite("Composite image cache storage")
struct CompositeImageCacheStorageTests {
    @Test("Returns memory image without reading disk")
    func returnsMemoryImageWithoutReadingDisk() async throws {
        let cachedImage = TestValues.cachedImage()
        let memoryStorage = ImageCacheStorageSpy(cachedImages: [TestValues.url: cachedImage])
        let diskStorage = ImageCacheStorageSpy()
        let storage = CompositeImageCacheStorage(
            memoryStorage: memoryStorage,
            diskStorage: diskStorage
        )

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let unwrappedResult = try #require(result)

        #expect(unwrappedResult.data == cachedImage.data)
        #expect(await memoryStorage.cachedImageCallCount() == 1)
        #expect(await diskStorage.cachedImageCallCount() == 0)
    }

    @Test("Warms memory cache after disk hit")
    func warmsMemoryCacheAfterDiskHit() async throws {
        let cachedImage = TestValues.cachedImage()
        let memoryStorage = ImageCacheStorageSpy()
        let diskStorage = ImageCacheStorageSpy(cachedImages: [TestValues.url: cachedImage])
        let storage = CompositeImageCacheStorage(
            memoryStorage: memoryStorage,
            diskStorage: diskStorage
        )

        let result = await storage.cachedImage(for: TestValues.url, now: TestValues.now)
        let unwrappedResult = try #require(result)
        let warmedImage = await memoryStorage.storedImage(for: TestValues.url)

        #expect(unwrappedResult.data == cachedImage.data)
        #expect(warmedImage?.data == cachedImage.data)
        #expect(await diskStorage.cachedImageCallCount() == 1)
        #expect(await memoryStorage.storeCallCount() == 1)
    }

    @Test("Stores image in memory and disk")
    func storesImageInMemoryAndDisk() async {
        let cachedImage = TestValues.cachedImage()
        let memoryStorage = ImageCacheStorageSpy()
        let diskStorage = ImageCacheStorageSpy()
        let storage = CompositeImageCacheStorage(
            memoryStorage: memoryStorage,
            diskStorage: diskStorage
        )

        await storage.store(cachedImage, for: TestValues.url)

        #expect(await memoryStorage.storedImage(for: TestValues.url)?.data == cachedImage.data)
        #expect(await diskStorage.storedImage(for: TestValues.url)?.data == cachedImage.data)
    }

    @Test("Removes image from memory and disk")
    func removesImageFromMemoryAndDisk() async {
        let memoryStorage = ImageCacheStorageSpy()
        let diskStorage = ImageCacheStorageSpy()
        let storage = CompositeImageCacheStorage(
            memoryStorage: memoryStorage,
            diskStorage: diskStorage
        )

        await storage.removeImage(for: TestValues.url)

        #expect(await memoryStorage.removeImageCallCount() == 1)
        #expect(await diskStorage.removeImageCallCount() == 1)
    }

    @Test("Removes all images from memory and disk")
    func removesAllImagesFromMemoryAndDisk() async {
        let memoryStorage = ImageCacheStorageSpy()
        let diskStorage = ImageCacheStorageSpy()
        let storage = CompositeImageCacheStorage(
            memoryStorage: memoryStorage,
            diskStorage: diskStorage
        )

        await storage.removeAllImages()

        #expect(await memoryStorage.removeAllImagesCallCount() == 1)
        #expect(await diskStorage.removeAllImagesCallCount() == 1)
    }
}
