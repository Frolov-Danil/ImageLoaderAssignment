import Foundation

final class PhotoAPIClient {
    private let photoListURL: URL?
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        photoListURL: URL?,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.photoListURL = photoListURL
        self.session = session
        self.decoder = decoder
    }

    func fetchPhotos() async throws -> [PhotoDTO] {
        guard let photoListURL else {
            return []
        }

        let data = try await data(from: photoListURL)
        return try decoder.decode([PhotoDTO].self, from: data)
    }
}

// MARK: - Private

private extension PhotoAPIClient {
    func data(from url: URL) async throws -> Data {
        if url.isFileURL {
            return try Data(contentsOf: url)
        }

        let (data, response) = try await session.data(from: url)
        try validate(response)
        return data
    }

    func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PhotoAPIClientError.invalidResponse
        }
    }
}

enum PhotoAPIClientError: Error {
    case invalidResponse
}
