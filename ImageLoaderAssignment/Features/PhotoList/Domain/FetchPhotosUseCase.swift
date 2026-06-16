struct FetchPhotosUseCase {
    private let repository: PhotoRepositoryProtocol

    init(repository: PhotoRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Photo] {
        try await repository.fetchPhotos()
    }
}
