import Foundation

final class URLSessionImageDownloader: ImageDownloadingProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              Constants.successStatusCodes.contains(httpResponse.statusCode) else {
            throw ImageLoadingError.invalidResponse
        }

        return data
    }
}

// MARK: - Constants

private extension URLSessionImageDownloader {
    enum Constants {
        static let successStatusCodes = 200..<300
    }
}
