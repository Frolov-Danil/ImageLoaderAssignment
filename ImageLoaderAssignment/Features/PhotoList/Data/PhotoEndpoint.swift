import Foundation

enum PhotoEndpoint {
    static func photos(url: URL) -> Endpoint<[PhotoDTO]> {
        Endpoint(url: url)
    }
}
