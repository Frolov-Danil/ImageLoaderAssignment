import Foundation

@MainActor
protocol ImagesListPresentationLogic: AnyObject {
    func presentLoading()
    func presentImages(response: ImagesList.LoadImages.Response)
    func presentCacheCleared(response: ImagesList.ClearCache.Response)
}

@MainActor
final class ImagesListPresenter: ImagesListPresentationLogic {
    weak var viewController: ImagesListDisplayLogic?

    func presentLoading() {
        viewController?.displayImages(viewModel: .init(state: .loading))
    }

    func presentImages(response: ImagesList.LoadImages.Response) {
        switch response.result {
        case let .success(items):
            let displayedImages = items.map {
                ImagesList.DisplayedImage(
                    id: $0.id,
                    subtitle: $0.url.absoluteString,
                    url: $0.url
                )
            }

            let state: ImagesList.LoadImages.State = displayedImages.isEmpty
                ? .empty
                : .content(displayedImages)

            viewController?.displayImages(viewModel: .init(state: state))

        case .failure:
            viewController?.displayImages(
                viewModel: .init(state: .error(message: "Failed to load images."))
            )
        }
    }

    func presentCacheCleared(response: ImagesList.ClearCache.Response) {
        viewController?.displayCacheCleared(
            viewModel: .init(message: "Image cache cleared.")
        )
    }
}
