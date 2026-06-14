import Foundation
import ImageLoadingKit

@MainActor
protocol ImagesListBusinessLogic: AnyObject {
    func loadImages(request: ImagesList.LoadImages.Request)
    func clearCache(request: ImagesList.ClearCache.Request)
}

@MainActor
final class ImagesListInteractor: ImagesListBusinessLogic {
    var presenter: ImagesListPresentationLogic?

    private let worker: ImagesListWorking
    private let cacheInvalidator: ImageCacheInvalidating

    init(
        worker: ImagesListWorking = ImagesListWorker(),
        cacheInvalidator: ImageCacheInvalidating = ImagePipeline.shared
    ) {
        self.worker = worker
        self.cacheInvalidator = cacheInvalidator
    }

    func loadImages(request: ImagesList.LoadImages.Request) {
        presenter?.presentLoading()

        Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let images = try await worker.fetchImages()
                presenter?.presentImages(response: .init(result: .success(images)))
            } catch {
                presenter?.presentImages(response: .init(result: .failure(error)))
            }
        }
    }

    func clearCache(request: ImagesList.ClearCache.Request) {
        Task { [weak self] in
            guard let self else {
                return
            }

            await cacheInvalidator.invalidateCache()
            presenter?.presentCacheCleared(response: .init())
        }
    }
}
