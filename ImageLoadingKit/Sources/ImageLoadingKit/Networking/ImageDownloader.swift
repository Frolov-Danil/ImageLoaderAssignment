import Foundation

protocol ImageDownloading {
    func data(from url: URL) async throws -> Data
}

final class URLSessionImageDownloader: ImageDownloading {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ImageLoadingError.invalidResponse
        }

        return data
    }
}
