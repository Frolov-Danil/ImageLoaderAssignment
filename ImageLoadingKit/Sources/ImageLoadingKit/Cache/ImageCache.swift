import Foundation

/// Provides manual cache invalidation for images loaded by `ImageLoadingKit`.
public enum ImageCache {
    /// Clears all cached images from memory and disk.
    ///
    /// In-flight image requests are cancelled as part of invalidation.
    public static func invalidate() async {
        await ImagePipeline.shared.invalidateCache()
    }
}
