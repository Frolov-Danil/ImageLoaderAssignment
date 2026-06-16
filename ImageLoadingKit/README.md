# ImageLoadingKit

`ImageLoadingKit` is a lightweight image loading library for iOS. It downloads remote images, caches them in memory and on disk, and provides ready-to-use UIKit and SwiftUI views.

## Overview

The package exposes a small public API centered around ready-to-use UIKit and SwiftUI image views. App code provides a URL and a placeholder; the library handles request lifetime, cache lookup, disk persistence, and image decoding internally.

The pipeline checks memory cache first, then disk cache, and only starts a network request when no valid cached image exists. Successful downloads are stored in both cache layers. Concurrent requests for the same URL share a single in-flight download task.

## Features

- Uses memory and disk cache.
- Keeps disk cache available across app launches.
- Expires cached images after 4 hours by default.
- Deduplicates concurrent requests for the same URL.
- Supports manual cache invalidation for all images or a specific URL.
- Includes UIKit and SwiftUI image views.

## Requirements

- iOS 15.0+
- Swift 6.0+

## UIKit

```swift
let imageView = AsyncImageView(
    url: imageURL,
    placeholder: UIImage(systemName: "photo.fill")
)
```

Update the image when the view is reused:

```swift
imageView.setImage(
    from: nextImageURL,
    placeholder: UIImage(systemName: "photo.fill")
)
```

Cancel loading if needed:

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
await ImageCache.invalidate()
```

Clear a single cached image:

```swift
await ImageCache.invalidate(imageURL)
```

## Cache Lifetime

Cached images are valid for 4 hours. This is an internal cache policy of the library.

Disk cache is stored in the app Caches directory and survives normal app relaunches.

## Error Handling

UIKit and SwiftUI views keep showing the provided placeholder if loading fails.

## Public API

- `AsyncImageView.init(url:placeholder:)`
- `AsyncImageView.setImage(from:placeholder:)`
- `AsyncImageView.cancelLoading()`
- `SwiftUIAsyncImageView.init(url:placeholder:)`
- `ImageCache.invalidate()`
- `ImageCache.invalidate(_:)`
