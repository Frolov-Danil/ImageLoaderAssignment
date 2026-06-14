import Foundation

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func request<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let data = try await data(from: endpoint.url)
        return try decoder.decode(Response.self, from: data)
    }
}

// MARK: - Private

private extension APIClient {
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
            throw APIClientError.invalidResponse
        }
    }
}

enum APIClientError: Error {
    case invalidResponse
}
