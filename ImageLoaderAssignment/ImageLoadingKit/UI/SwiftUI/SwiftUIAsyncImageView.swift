import SwiftUI

struct SwiftUIAsyncImageView<Placeholder: View>: View {
    private let url: URL?
    private let placeholder: Placeholder

    @State private var image: UIImage?

    init(
        url: URL?,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.placeholder = placeholder()
    }

    var body: some View {
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

    @MainActor
    private func loadImage() async {
        image = nil

        guard let url else {
            return
        }

        image = try? await ImagePipeline.shared.image(for: url)
    }
}
