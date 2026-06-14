# ImageLoadingKit

`ImageLoadingKit` is a lightweight image loading library for iOS. It downloads remote images, caches them in memory and on disk, and provides ready-to-use UIKit and SwiftUI views.

## Overview

The package exposes a small public API centered around `ImagePipeline`. UIKit and SwiftUI convenience views use the shared pipeline by default, so app code can display remote images without managing request lifetime, cache lookup, or disk persistence manually.

The pipeline checks memory cache first, then disk cache, and only starts a network request when no valid cached image exists. Successful downloads are stored in both cache layers. Concurrent requests for the same URL share a single in-flight download task.

## Features

- Uses memory and disk cache.
- Keeps disk cache available across app launches.
- Expires cached images after 4 hours by default.
- Deduplicates concurrent requests for the same URL.
- Supports manual cache invalidation.
- Includes UIKit and SwiftUI image views.

## Requirements

- iOS 15.0+
- Swift 5.9+

## UIKit

```swift
let imageView = AsyncImageView()
imageView.setImage(
    from: imageURL,
    placeholder: UIImage(systemName: "photo.fill")
)
```

Cancel loading when the view is reused:

```swift
imageView.cancelLoading()
```

## SwiftUI

```swift
SwiftUIAsyncImageView(url: imageURL) {
    ProgressView()
}
.aspectRatio(contentMode: .fill)
```

## Cache Invalidation

Clear the entire cache:

```swift
await ImagePipeline.shared.invalidateCache()
```

Clear a specific cached image:

```swift
await ImagePipeline.shared.invalidateCache(for: imageURL)
```

## Direct Pipeline Usage

UIKit and SwiftUI views use `ImagePipeline.shared` by default. You can also use the shared pipeline directly when you need an image outside the provided views:

```swift
let image = try await ImagePipeline.shared.image(for: imageURL)
```

## Cache Lifetime

Cached images are valid for 4 hours by default:

```swift
ImagePipeline.defaultCacheExpirationInterval
```

The provided UIKit and SwiftUI components use this default cache policy.

## Error Handling

`ImagePipeline.image(for:)` throws `ImageLoadingError.invalidResponse` when the server response is not successful and `ImageLoadingError.invalidImageData` when downloaded data cannot be decoded as an image. URL loading errors from `URLSession` are propagated to the caller.

## Public API

- `AsyncImageView.init()`
- `AsyncImageView.setImage(from:placeholder:)`
- `AsyncImageView.cancelLoading()`
- `SwiftUIAsyncImageView.init(url:placeholder:)`
- `ImagePipeline.shared`
- `ImagePipeline.defaultCacheExpirationInterval`
- `ImagePipeline.image(for:)`
- `ImagePipeline.invalidateCache()`
- `ImagePipeline.invalidateCache(for:)`
- `ImageLoadingError`
