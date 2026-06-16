import Foundation
import Testing
@testable import ImageLoadingKit

@Suite("Cached image")
struct CachedImageTests {
    @Test("Image is valid before expiration date")
    func imageIsValidBeforeExpirationDate() {
        let cachedImage = TestValues.cachedImage(
            expiresAt: TestValues.now.addingTimeInterval(60)
        )

        #expect(cachedImage.isValid(at: TestValues.now))
    }

    @Test("Image is invalid at expiration date")
    func imageIsInvalidAtExpirationDate() {
        let cachedImage = TestValues.cachedImage(expiresAt: TestValues.now)

        #expect(!cachedImage.isValid(at: TestValues.now))
    }

    @Test("Image is invalid after expiration date")
    func imageIsInvalidAfterExpirationDate() {
        let cachedImage = TestValues.cachedImage(expiresAt: TestValues.now)

        #expect(!cachedImage.isValid(at: TestValues.now.addingTimeInterval(1)))
    }
}
