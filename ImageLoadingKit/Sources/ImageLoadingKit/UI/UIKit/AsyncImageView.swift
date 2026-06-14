import UIKit

/// A UIKit image view that displays remote images using `ImagePipeline`.
///
/// `AsyncImageView` shows a placeholder immediately, downloads the requested
/// image asynchronously, and updates itself only if it still represents the same
/// URL when the request finishes. This makes the view safe to use in reusable
/// cells.
public final class AsyncImageView: UIImageView {
    private let imagePipeline: ImagePipeline
    private var loadingTask: Task<Void, Never>?
    private var representedURL: URL?

    /// Creates an async image view backed by the shared image pipeline.
    public init() {
        self.imagePipeline = ImagePipeline.shared
        super.init(frame: .zero)
        configureView()
    }

    init(imagePipeline: ImagePipeline) {
        self.imagePipeline = imagePipeline
        super.init(frame: .zero)
        configureView()
    }

    /// Creates an async image view from data in an unarchiver.
    ///
    /// The decoded view uses the shared image pipeline.
    public required init?(coder: NSCoder) {
        self.imagePipeline = ImagePipeline.shared
        super.init(coder: coder)
        configureView()
    }

    deinit {
        loadingTask?.cancel()
    }

    /// Loads and displays an image from the specified URL.
    ///
    /// The placeholder is assigned immediately. Passing `nil` cancels the
    /// current request, keeps the placeholder as the current image, and clears
    /// the represented URL.
    ///
    /// - Parameters:
    ///   - url: The remote image URL to load.
    ///   - placeholder: The image to display while the remote image is loading.
    public func setImage(from url: URL?, placeholder: UIImage? = nil) {
        loadingTask?.cancel()
        representedURL = url
        image = placeholder

        guard let url else {
            return
        }

        loadingTask = Task { [weak self] in
            do {
                let loadedImage = try await self?.imagePipeline.image(for: url)

                guard !Task.isCancelled, self?.representedURL == url else {
                    return
                }

                self?.image = loadedImage
            } catch {
                return
            }
        }
    }

    /// Cancels the current image request and clears the represented URL.
    ///
    /// Call this method before reusing a cell that owns an `AsyncImageView`.
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
