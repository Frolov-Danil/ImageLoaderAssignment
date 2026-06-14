import Foundation

enum AppConfiguration {
    static var imageListURL: URL? {
        Bundle.main.url(
            forResource: Constants.imageListResourceName,
            withExtension: Constants.imageListResourceExtension
        )
    }
}

// MARK: - Constants

private extension AppConfiguration {
    enum Constants {
        static let imageListResourceName = "photos"
        static let imageListResourceExtension = "json"
    }
}
