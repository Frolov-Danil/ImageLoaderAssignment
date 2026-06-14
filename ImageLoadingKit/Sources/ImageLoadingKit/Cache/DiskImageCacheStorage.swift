import CryptoKit
import Foundation

final class DiskImageCacheStorage: ImageCacheStorageProtocol {
    private let directoryURL: URL
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        self.directoryURL = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Constants.cacheDirectoryName, isDirectory: true)
    }

    func cachedImage(for url: URL, now: Date) async -> CachedImage? {
        guard let metadata = metadata(for: url),
              metadata.isValid(at: now),
              let data = try? Data(contentsOf: dataFileURL(for: url)) else {
            await removeImage(for: url)
            return nil
        }

        return CachedImage(data: data, metadata: metadata)
    }

    func store(_ cachedImage: CachedImage, for url: URL) async {
        do {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
            try cachedImage.data.write(to: dataFileURL(for: url), options: .atomic)

            let metadataData = try encoder.encode(cachedImage.metadata)
            try metadataData.write(to: metadataFileURL(for: url), options: .atomic)
        } catch {
            return
        }
    }

    func removeImage(for url: URL) async {
        try? fileManager.removeItem(at: dataFileURL(for: url))
        try? fileManager.removeItem(at: metadataFileURL(for: url))
    }

    func removeAllImages() async {
        try? fileManager.removeItem(at: directoryURL)
    }
}

// MARK: - Private

private extension DiskImageCacheStorage {
    func metadata(for url: URL) -> CachedImage.Metadata? {
        guard let data = try? Data(contentsOf: metadataFileURL(for: url)) else {
            return nil
        }

        return try? decoder.decode(CachedImage.Metadata.self, from: data)
    }

    func dataFileURL(for url: URL) -> URL {
        directoryURL.appendingPathComponent("\(cacheKey(for: url)).\(Constants.dataFileExtension)")
    }

    func metadataFileURL(for url: URL) -> URL {
        directoryURL.appendingPathComponent("\(cacheKey(for: url)).\(Constants.metadataFileExtension)")
    }

    func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Constants

private extension DiskImageCacheStorage {
    enum Constants {
        static let cacheDirectoryName = "ImageLoadingKit"
        static let dataFileExtension = "data"
        static let metadataFileExtension = "metadata.json"
    }
}
