import Foundation

final class URLSessionImageDownloader: ImageDownloadingProtocol {
    private let session: URLSession

    init() {
        self.session = URLSessionImageDownloader.makeEphemeralSession()
    }

    init(session: URLSession) {
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
    static func makeEphemeralSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil

        return URLSession(configuration: configuration)
    }

    enum Constants {
        static let successStatusCodes = 200..<300
    }
}
