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
        let viewModel = PhotoListViewModel(fetchPhotosUseCase: fetchPhotosUseCase)
        let viewController = PhotoListViewController(viewModel: viewModel)

        return UINavigationController(rootViewController: viewController)
    }
}
