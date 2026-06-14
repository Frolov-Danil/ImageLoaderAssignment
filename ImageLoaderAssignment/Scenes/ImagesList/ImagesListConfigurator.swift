import UIKit

@MainActor
enum ImagesListConfigurator {
    static func makeScene() -> UIViewController {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenter()
        let interactor = ImagesListInteractor()

        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController

        return UINavigationController(rootViewController: viewController)
    }
}
