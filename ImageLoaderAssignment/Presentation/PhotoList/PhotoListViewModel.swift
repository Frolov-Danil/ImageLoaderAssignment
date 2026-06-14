import Foundation

@MainActor
final class PhotoListViewModel {
    var onStateChange: ((PhotoListState) -> Void)?
    var onCacheCleared: ((String) -> Void)?

    private let fetchPhotosUseCase: FetchPhotosUseCase
    private let clearImageCacheUseCase: ClearImageCacheUseCase

    private var loadTask: Task<Void, Never>?
    private var clearCacheTask: Task<Void, Never>?

    init(
        fetchPhotosUseCase: FetchPhotosUseCase,
        clearImageCacheUseCase: ClearImageCacheUseCase
    ) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.clearImageCacheUseCase = clearImageCacheUseCase
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
                onStateChange?(cellViewStates.isEmpty ? .empty : .content(cellViewStates))
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                onStateChange?(.error(message: "Failed to load images."))
            }
        }
    }

    func clearCache() {
        clearCacheTask?.cancel()

        clearCacheTask = Task { [weak self] in
            guard let self else {
                return
            }

            await clearImageCacheUseCase.execute()

            guard !Task.isCancelled else {
                return
            }

            onCacheCleared?("Image cache cleared.")
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
