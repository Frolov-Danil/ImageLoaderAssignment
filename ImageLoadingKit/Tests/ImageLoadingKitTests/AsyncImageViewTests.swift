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

    @Test("Loads image using injected pipeline")
    func loadsImageUsingInjectedPipeline() async throws {
        let cache = ImageCacheStorageSpy()
        let downloader = ImageDownloaderSpy(data: TestValues.pngData)
        let pipeline = ImagePipeline(downloader: downloader, cache: cache)

        let imageView = AsyncImageView(
            url: TestValues.url,
            imagePipeline: pipeline
        )

        try await waitForLoadedImage(in: imageView)

        #expect(imageView.image != nil)
        #expect(await downloader.requestCount() == 1)
    }
}

// MARK: - Private

private extension AsyncImageViewTests {
    func waitForLoadedImage(in imageView: AsyncImageView) async throws {
        for _ in 0..<10 {
            if imageView.image != nil {
                return
            }

            try await Task.sleep(nanoseconds: 50_000_000)
        }

        Issue.record("Expected image view to load an image")
    }
}
