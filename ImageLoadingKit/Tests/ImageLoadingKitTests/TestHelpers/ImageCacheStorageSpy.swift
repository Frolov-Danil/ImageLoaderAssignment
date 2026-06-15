import Foundation
@testable import ImageLoadingKit

actor ImageCacheStorageSpy: ImageCacheStorageProtocol {
    private var cachedImages: [URL: CachedImage]
    private var cachedImageCalls: [URL] = []
    private var storeCalls: [URL] = []
    private var removeImageCalls: [URL] = []
    private var removeAllImagesCallsCount = 0

    init(cachedImages: [URL: CachedImage] = [:]) {
        self.cachedImages = cachedImages
    }

    func cachedImage(for url: URL, now: Date) async -> CachedImage? {
        cachedImageCalls.append(url)
        return cachedImages[url]
    }

    func store(_ cachedImage: CachedImage, for url: URL) async {
        storeCalls.append(url)
        cachedImages[url] = cachedImage
    }

    func removeImage(for url: URL) async {
        removeImageCalls.append(url)
        cachedImages[url] = nil
    }

    func removeAllImages() async {
        removeAllImagesCallsCount += 1
        cachedImages.removeAll()
    }

    func cachedImageCallCount() -> Int {
        cachedImageCalls.count
    }

    func storeCallCount() -> Int {
        storeCalls.count
    }

    func removeImageCallCount() -> Int {
        removeImageCalls.count
    }

    func removeAllImagesCallCount() -> Int {
        removeAllImagesCallsCount
    }

    func storedImage(for url: URL) -> CachedImage? {
        cachedImages[url]
    }
}
