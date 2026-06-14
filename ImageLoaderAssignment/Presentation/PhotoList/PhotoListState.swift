enum PhotoListState: Equatable {
    case loading
    case content([PhotoCellViewState])
    case empty
    case error(message: String)
}
