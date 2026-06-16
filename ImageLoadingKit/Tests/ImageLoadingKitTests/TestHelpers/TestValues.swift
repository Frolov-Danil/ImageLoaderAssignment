import Foundation
import UIKit
@testable import ImageLoadingKit

enum TestValues {
    static let url = URL(string: "https://example.com/image.png")!
    static let anotherURL = URL(string: "https://example.com/another-image.png")!
    static let now = Date(timeIntervalSince1970: 1_700_000_000)
    static let invalidImageData = Data("invalid image data".utf8)
    static let pngData: Data = {
        let size = CGSize(width: 1, height: 1)
        let bounds = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: size, format: format).pngData { context in
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            context.cgContext.fill(bounds)
        }
    }()

    static func cachedImage(
        url: URL = url,
        data: Data = Data([0, 1, 2, 3]),
        cachedAt: Date = now,
        expiresAt: Date = now.addingTimeInterval(60)
    ) -> CachedImage {
        CachedImage(
            data: data,
            metadata: CachedImage.Metadata(
                originalURL: url,
                cachedAt: cachedAt,
                expiresAt: expiresAt
            )
        )
    }
}
