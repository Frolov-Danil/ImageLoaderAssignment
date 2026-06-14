import UIKit

public final class AsyncImageView: UIImageView {
    private let imageLoader: ImageLoading
    private var loadingTask: Task<Void, Never>?
    private var representedURL: URL?

    public init(imageLoader: ImageLoading = ImagePipeline.shared) {
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        configureView()
    }

    public required init?(coder: NSCoder) {
        self.imageLoader = ImagePipeline.shared
        super.init(coder: coder)
        configureView()
    }

    deinit {
        loadingTask?.cancel()
    }

    public func setImage(from url: URL?, placeholder: UIImage? = nil) {
        loadingTask?.cancel()
        representedURL = url
        image = placeholder

        guard let url else {
            return
        }

        loadingTask = Task { [weak self] in
            do {
                let loadedImage = try await self?.imageLoader.image(for: url)

                guard !Task.isCancelled, self?.representedURL == url else {
                    return
                }

                self?.image = loadedImage
            } catch {
                return
            }
        }
    }

    public func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        representedURL = nil
    }
}

// MARK: - Private

private extension AsyncImageView {
    func configureView() {
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }
}
