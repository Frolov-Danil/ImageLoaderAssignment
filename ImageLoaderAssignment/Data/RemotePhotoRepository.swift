final class RemotePhotoRepository: PhotoRepository {
    private let apiClient: PhotoAPIClient

    init(apiClient: PhotoAPIClient) {
        self.apiClient = apiClient
    }

    func fetchPhotos() async throws -> [Photo] {
        try await apiClient
            .fetchPhotos()
            .map(PhotoMapper.map)
    }
}
