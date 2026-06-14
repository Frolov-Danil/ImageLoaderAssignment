import UIKit

@MainActor
enum RootViewControllerFactory {
    static func makeRootViewController() -> UIViewController {
        let apiClient = PhotoAPIClient(photoListURL: AppConfiguration.imageListURL)
        let repository = RemotePhotoRepository(apiClient: apiClient)
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
