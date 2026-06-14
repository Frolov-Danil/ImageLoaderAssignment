protocol PhotoRepository {
    func fetchPhotos() async throws -> [Photo]
}
