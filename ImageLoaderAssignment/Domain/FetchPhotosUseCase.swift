struct FetchPhotosUseCase {
    private let repository: PhotoRepository

    init(repository: PhotoRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Photo] {
        try await repository.fetchPhotos()
    }
}
