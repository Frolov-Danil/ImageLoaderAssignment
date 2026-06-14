import Foundation

protocol ImageDownloadingProtocol {
    func data(from url: URL) async throws -> Data
}
