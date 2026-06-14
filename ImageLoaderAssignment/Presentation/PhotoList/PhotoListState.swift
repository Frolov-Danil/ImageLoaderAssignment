import Foundation

enum PhotoListState: Equatable {
    case loading
    case content([PhotoCellViewModel])
    case empty
    case error(message: String)
}

struct PhotoCellViewModel: Equatable {
    let id: String
    let url: URL
    let subtitle: String
}
