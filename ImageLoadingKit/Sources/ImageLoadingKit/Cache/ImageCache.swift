import Foundation

/// Provides manual cache invalidation for images loaded by `ImageLoadingKit`.
public enum ImageCache {
    /// Clears all cached images from memory and disk.
    ///
    /// In-flight image requests are cancelled as part of invalidation.
    public static func invalidate() async {
        await ImagePipeline.shared.invalidateCache()
    }

    /// Clears the cached image for the specified URL from memory and disk.
    ///
    /// An in-flight request for the same URL is cancelled as part of invalidation.
    public static func invalidate(_ url: URL) async {
        await ImagePipeline.shared.invalidateCache(for: url)
    }
}
