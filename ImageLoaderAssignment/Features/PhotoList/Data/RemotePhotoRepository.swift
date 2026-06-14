import Foundation

final class RemotePhotoRepository: PhotoRepositoryProtocol {
    private let apiClient: APIClient
    private let photoListURL: URL?

    init(
        apiClient: APIClient,
        photoListURL: URL?
    ) {
        self.apiClient = apiClient
        self.photoListURL = photoListURL
    }

    func fetchPhotos() async throws -> [Photo] {
        guard let photoListURL else {
            return []
        }

        let photosDTO: [PhotoDTO] = try await apiClient.request(
            PhotoEndpoint.photos(url: photoListURL)
        )

        return photosDTO.map(PhotoMapper.map)
    }
}
