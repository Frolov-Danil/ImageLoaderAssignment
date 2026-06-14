import Foundation

/// An error produced by `ImageLoadingKit` while loading an image.
public enum ImageLoadingError: Error {
    /// The server returned a response outside the successful HTTP status range.
    case invalidResponse

    /// Downloaded data could not be decoded as an image.
    case invalidImageData
}
