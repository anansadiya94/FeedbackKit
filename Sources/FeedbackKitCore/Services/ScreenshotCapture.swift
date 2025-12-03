#if canImport(UIKit)
import UIKit

/// Service for capturing screenshots of the current window
public struct ScreenshotCapture: Sendable {
    public init() {}

    /// Capture a screenshot of the current key window
    ///
    /// - Returns: A UIImage of the current window, or nil if capture fails
    public func capture() -> UIImage? {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { _ in
            // drawHierarchy gives a better result than layer.render(in:)
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
    }
}
#else
import Foundation

/// Service for capturing screenshots of the current window (macOS placeholder)
public struct ScreenshotCapture: Sendable {
    public init() {}

    /// Capture a screenshot - not available on macOS
    public func capture() -> Never {
        fatalError("ScreenshotCapture is only available on iOS")
    }
}
#endif
