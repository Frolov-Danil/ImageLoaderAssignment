import Foundation
@testable import ImageLoadingKit

actor ImageDownloaderSpy: ImageDownloadingProtocol {
    private let result: Result<Data, Error>
    private let delayNanoseconds: UInt64
    private var requestedURLs: [URL] = []

    init(
        data: Data,
        delayNanoseconds: UInt64 = 0
    ) {
        self.result = .success(data)
        self.delayNanoseconds = delayNanoseconds
    }

    init(
        error: Error,
        delayNanoseconds: UInt64 = 0
    ) {
        self.result = .failure(error)
        self.delayNanoseconds = delayNanoseconds
    }

    func data(from url: URL) async throws -> Data {
        requestedURLs.append(url)

        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        return try result.get()
    }

    func requestCount() -> Int {
        requestedURLs.count
    }
}
