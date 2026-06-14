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

        let (data, response) = try await session.data(from: photoListURL)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw PhotoAPIClientError.invalidResponse
        }

        return try decoder.decode([PhotoDTO].self, from: data)
    }
}

enum PhotoAPIClientError: Error {
    case invalidResponse
}
