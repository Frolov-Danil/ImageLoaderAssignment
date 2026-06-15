import Testing
import UIKit
@testable import ImageLoadingKit

@Suite("Async image view")
@MainActor
struct AsyncImageViewTests {
    @Test("Displays placeholder immediately")
    func displaysPlaceholderImmediately() throws {
        let placeholder = try #require(UIImage(data: TestValues.pngData))

        let imageView = AsyncImageView(url: nil, placeholder: placeholder)

        #expect(imageView.image?.pngData() == placeholder.pngData())
    }
}
