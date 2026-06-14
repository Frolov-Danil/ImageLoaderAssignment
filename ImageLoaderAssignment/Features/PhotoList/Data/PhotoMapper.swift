enum PhotoMapper {
    static func map(_ dto: PhotoDTO) -> Photo {
        Photo(id: dto.id, url: dto.url)
    }
}
