enum PhotoListState: Equatable {
    case loading
    case content([PhotoCellViewState])
    case empty(message: String)
    case error(message: String)
}
