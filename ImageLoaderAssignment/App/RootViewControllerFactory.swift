import UIKit

@MainActor
enum RootViewControllerFactory {
    static func makeRootViewController() -> UIViewController {
        let apiClient = APIClient()
        let repository = RemotePhotoRepository(
            apiClient: apiClient,
            photoListURL: AppConfiguration.imageListURL
        )
        let fetchPhotosUseCase = FetchPhotosUseCase(repository: repository)
        let imageCache = ImageLoadingKitCacheAdapter()
        let clearImageCacheUseCase = ClearImageCacheUseCase(imageCache: imageCache)
        let viewModel = PhotoListViewModel(
            fetchPhotosUseCase: fetchPhotosUseCase,
            clearImageCacheUseCase: clearImageCacheUseCase
        )
        let viewController = PhotoListViewController(viewModel: viewModel)

        return UINavigationController(rootViewController: viewController)
    }
}
