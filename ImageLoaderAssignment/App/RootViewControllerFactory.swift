import UIKit

@MainActor
enum RootViewControllerFactory {
    static func makeRootViewController() -> UIViewController {
        ImagesListConfigurator.makeScene()
    }
}
