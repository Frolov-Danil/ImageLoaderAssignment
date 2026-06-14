import Foundation

final class MemoryImageCache: ImageCache {
    private let cache = NSCache<NSURL, NSData>()

    func data(for url: URL) async -> Data? {
        cache.object(forKey: url as NSURL) as Data?
    }

    func store(_ data: Data, for url: URL) async {
        cache.setObject(data as NSData, forKey: url as NSURL)
    }

    func removeData(for url: URL) async {
        cache.removeObject(forKey: url as NSURL)
    }

    func removeAllData() async {
        cache.removeAllObjects()
    }
}
