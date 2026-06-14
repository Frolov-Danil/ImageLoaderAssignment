import Foundation

protocol ImageCache: AnyObject {
    func data(for url: URL) async -> Data?
    func store(_ data: Data, for url: URL) async
    func removeData(for url: URL) async
    func removeAllData() async
}
