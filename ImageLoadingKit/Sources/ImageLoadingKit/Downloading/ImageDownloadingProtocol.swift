import Foundation

protocol ImageDownloadingProtocol: Sendable {
    func data(from url: URL) async throws -> Data
}
