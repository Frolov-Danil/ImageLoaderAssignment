import Foundation

enum ImagesList {
    enum LoadImages {
        struct Request {}

        struct Response {
            let result: Result<[ImageItem], Error>
        }

        struct ViewModel {
            let state: State
        }

        enum State {
            case loading
            case content([DisplayedImage])
            case empty
            case error(message: String)
        }
    }

    enum ClearCache {
        struct Request {}
        struct Response {}

        struct ViewModel {
            let message: String
        }
    }

    struct ImageItem {
        let id: String
        let url: URL
    }

    struct DisplayedImage {
        let id: String
        let subtitle: String
        let url: URL
    }
}
