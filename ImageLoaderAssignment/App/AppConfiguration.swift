import Foundation

enum AppConfiguration {
    static var imageListURL: URL? {
        Bundle.main.url(forResource: "photos", withExtension: "json")
    }
}
