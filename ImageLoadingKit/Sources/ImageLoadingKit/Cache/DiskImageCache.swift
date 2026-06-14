import CryptoKit
import Foundation

final class DiskImageCache: ImageCache {
    private let directoryURL: URL
    private let fileManager: FileManager

    init(
        directoryURL: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.directoryURL = directoryURL ?? fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageLoadingKit", isDirectory: true)
    }

    func data(for url: URL) async -> Data? {
        try? Data(contentsOf: fileURL(for: url))
    }

    func store(_ data: Data, for url: URL) async {
        do {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL(for: url), options: .atomic)
        } catch {
            return
        }
    }

    func removeData(for url: URL) async {
        try? fileManager.removeItem(at: fileURL(for: url))
    }

    func removeAllData() async {
        try? fileManager.removeItem(at: directoryURL)
    }

    private func fileURL(for url: URL) -> URL {
        directoryURL.appendingPathComponent(cacheKey(for: url))
    }

    private func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
