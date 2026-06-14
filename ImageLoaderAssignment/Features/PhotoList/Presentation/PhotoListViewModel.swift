import Foundation
import ImageLoadingKit

@MainActor
final class PhotoListViewModel {
    var onStateChange: ((PhotoListState) -> Void)?
    var onCacheCleared: ((String) -> Void)?

    private let fetchPhotosUseCase: FetchPhotosUseCase

    private var loadTask: Task<Void, Never>?
    private var clearCacheTask: Task<Void, Never>?

    init(fetchPhotosUseCase: FetchPhotosUseCase) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
    }

    deinit {
        loadTask?.cancel()
        clearCacheTask?.cancel()
    }

    func loadPhotos() {
        loadTask?.cancel()
        onStateChange?(.loading)

        loadTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let photos = try await fetchPhotosUseCase.execute()

                guard !Task.isCancelled else {
                    return
                }

                let cellViewStates = makeCellViewStates(from: photos)

                if cellViewStates.isEmpty {
                    onStateChange?(.empty(message: Constants.emptyStateMessage))
                } else {
                    onStateChange?(.content(cellViewStates))
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                onStateChange?(.error(message: Constants.loadingErrorMessage))
            }
        }
    }

    func clearCache() {
        clearCacheTask?.cancel()

        clearCacheTask = Task { [weak self] in
            guard let self else {
                return
            }

            await ImageCache.invalidate()

            guard !Task.isCancelled else {
                return
            }

            onCacheCleared?(Constants.cacheClearedMessage)
        }
    }
}

// MARK: - Private

private extension PhotoListViewModel {
    func makeCellViewStates(from photos: [Photo]) -> [PhotoCellViewState] {
        photos.map {
            PhotoCellViewState(
                id: $0.id,
                url: $0.url,
                subtitle: $0.url.absoluteString
            )
        }
    }
}

// MARK: - Constants

private extension PhotoListViewModel {
    enum Constants {
        static let emptyStateMessage = "No images available yet."
        static let loadingErrorMessage = "Failed to load images."
        static let cacheClearedMessage = "Image cache cleared."
    }
}
