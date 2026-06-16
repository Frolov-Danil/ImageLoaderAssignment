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

## Deployment Target

The example app targets iOS 18.0 intentionally as a modern baseline for the demo application.

The reusable `ImageLoadingKit` package supports iOS 15.0+, so it can be integrated into apps with broader deployment requirements.

## Cache Invalidation Behavior

The "Clear Cache" button invalidates both memory and disk cache and shows a confirmation alert.

Currently visible images are not forcefully reloaded on purpose. This makes it possible to verify the persistence scenario manually: after clearing the cache, relaunch the app and observe that images are downloaded again instead of being restored from disk cache.

## Notes

The assignment archive did not include a JSON endpoint, so the demo app uses a bundled `photos.json` file with the expected `id` and `url` schema. `APIClient` still supports remote HTTP JSON sources, and the data source remains isolated in `AppConfiguration.imageListURL`.
