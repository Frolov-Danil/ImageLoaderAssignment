import Foundation

struct PhotoDTO: Decodable {
    let id: String
    let url: URL

    private enum CodingKeys: String, CodingKey {
        case id
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = try String(container.decode(Int.self, forKey: .id))
        }

        url = try container.decode(URL.self, forKey: .url)
    }
}
