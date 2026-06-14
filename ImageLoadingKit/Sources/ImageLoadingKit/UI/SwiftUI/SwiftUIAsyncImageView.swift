import SwiftUI

/// A SwiftUI view that displays a remote image.
///
/// The view renders the provided placeholder until the image finishes loading.
/// Loaded images use the same memory and disk cache behavior as the UIKit image view.
public struct SwiftUIAsyncImageView<Placeholder: View>: View {
    private let url: URL?
    private let placeholder: Placeholder

    @State private var image: UIImage?

    /// Creates a SwiftUI async image view with a custom placeholder.
    ///
    /// - Parameters:
    ///   - url: The remote image URL to load.
    ///   - placeholder: A view displayed while the image is loading.
    public init(
        url: URL?,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.placeholder = placeholder()
    }

    /// The content and behavior of the async image view.
    public var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }
}

// MARK: - Private

private extension SwiftUIAsyncImageView {
    @MainActor
    func loadImage() async {
        image = nil

        guard let url else {
            return
        }

        image = try? await ImagePipeline.shared.image(for: url)
    }
}
