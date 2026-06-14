import Foundation

protocol ImagesListWorking {
    func fetchImages() async throws -> [ImagesList.ImageItem]
}

final class ImagesListWorker: ImagesListWorking {
    private let imageListURL: URL?
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        imageListURL: URL? = AppConfiguration.imageListURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.imageListURL = imageListURL
        self.session = session
        self.decoder = decoder
    }

    func fetchImages() async throws -> [ImagesList.ImageItem] {
        guard let imageListURL else {
            return []
        }

        let (data, response) = try await session.data(from: imageListURL)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw ImagesListWorkerError.invalidResponse
        }

        return try decoder
            .decode([ImageDTO].self, from: data)
            .map { ImagesList.ImageItem(id: $0.id, url: $0.url) }
    }
}

private struct ImageDTO: Decodable {
    let id: String
    let url: URL

    private enum CodingKeys: String, CodingKey {
        case id
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = try String(container.decode(Int.self, forKey: .id))
        }

        url = try container.decode(URL.self, forKey: .url)
    }
}

private enum ImagesListWorkerError: Error {
    case invalidResponse
}
