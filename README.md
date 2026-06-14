# ImageLoaderAssignment

Small iOS assignment project for downloading, caching, and displaying remote images without third-party SDKs.

## Architecture

- `ImageLoadingKit` contains the reusable image loading layer.
- `Scenes/ImagesList` uses a lightweight Clean Swift flow: ViewController -> Interactor -> Worker -> Presenter -> ViewController.
- UIKit is used for the example app to keep the Clean Swift boundaries explicit.
- SwiftUI support is prepared through `SwiftUIAsyncImageView`.
- The current cache uses memory + disk layers. TTL and request deduplication will be added in the next implementation steps.

## Git Flow

- `main` keeps the stable assignment state.
- `develop` is the integration branch.
- Feature work is done in `feature/*` branches.

## Notes

The assignment archive did not include a JSON endpoint. The app keeps it isolated in `AppConfiguration.imageListURL` so it can be set in one place once the endpoint is known.
