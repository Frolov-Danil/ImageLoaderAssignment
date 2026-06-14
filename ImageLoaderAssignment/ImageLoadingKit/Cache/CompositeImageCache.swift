import Foundation

final class CompositeImageCache: ImageCache {
    private let primaryCache: ImageCache
    private let secondaryCache: ImageCache

    init(primaryCache: ImageCache, secondaryCache: ImageCache) {
        self.primaryCache = primaryCache
        self.secondaryCache = secondaryCache
    }

    func data(for url: URL) async -> Data? {
        if let data = await primaryCache.data(for: url) {
            return data
        }

        guard let data = await secondaryCache.data(for: url) else {
            return nil
        }

        await primaryCache.store(data, for: url)
        return data
    }

    func store(_ data: Data, for url: URL) async {
        await primaryCache.store(data, for: url)
        await secondaryCache.store(data, for: url)
    }

    func removeData(for url: URL) async {
        await primaryCache.removeData(for: url)
        await secondaryCache.removeData(for: url)
    }

    func removeAllData() async {
        await primaryCache.removeAllData()
        await secondaryCache.removeAllData()
    }
}
