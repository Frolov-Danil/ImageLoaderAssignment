# ImageLoaderAssignment

Small iOS assignment project for downloading, caching, and displaying remote images without third-party SDKs.

## Architecture

- `ImageLoadingKit` is a local Swift Package that contains the reusable image loading layer.
- `Scenes/ImagesList` uses a lightweight Clean Swift flow: ViewController -> Interactor -> Worker -> Presenter -> ViewController.
- UIKit is used for the example app to keep the Clean Swift boundaries explicit.
- UIKit and SwiftUI entry points are exposed by the package.
- The image pipeline is actor-isolated and deduplicates concurrent requests for the same URL.
- The cache uses memory + disk layers and stores disk metadata with a default 4-hour expiration.
- Manual cache invalidation clears memory, disk, and matching in-flight requests.

## Git Flow

- `main` keeps the stable assignment state.
- `develop` is the integration branch.
- Feature work is done in `feature/*` branches.

## Notes

The assignment archive did not include a JSON endpoint. The app keeps it isolated in `AppConfiguration.imageListURL` so it can be set in one place once the endpoint is known.
