protocol PhotoRepositoryProtocol {
    func fetchPhotos() async throws -> [Photo]
}
