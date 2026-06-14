# ImageLoaderAssignment

Small iOS assignment project for downloading, caching, and displaying remote images without third-party SDKs.

## Architecture

- `ImageLoadingKit` is a local Swift Package that contains the reusable image loading layer.
- The demo app uses MVVM with a lightweight Clean Architecture approach.
- `Core` contains reusable app infrastructure such as endpoint-based networking.
- `Features/PhotoList` contains the feature-specific Presentation, Domain, and Data layers.
- `App` acts as the composition root and wires concrete dependencies together.
- UIKit is used for the example app, while the image loading SDK remains independent and reusable.
- UIKit and SwiftUI entry points are exposed by the package.
- The image pipeline is actor-isolated and deduplicates concurrent requests for the same URL.
- The cache uses memory + disk layers and stores disk metadata with a default 4-hour expiration.
- Manual cache invalidation clears memory, disk, and matching in-flight requests.

## Git Flow

- `main` keeps the stable assignment state.
- `develop` is the integration branch.
- Branch prefixes are chosen by change type: `feature/*`, `refactor/*`, `fix/*`, or `chore/*`.

## Notes

The assignment archive did not include a JSON endpoint, so the demo app uses a bundled `photos.json` file with the expected `id` and `url` schema. `APIClient` still supports remote HTTP JSON sources, and the data source remains isolated in `AppConfiguration.imageListURL`.
