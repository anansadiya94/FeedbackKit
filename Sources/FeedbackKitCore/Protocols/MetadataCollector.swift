import Foundation

/// A protocol for collecting app and device metadata
public protocol MetadataCollector: Sendable {
    /// Collect current metadata about the app and device
    ///
    /// - Returns: Metadata containing app version, device info, etc.
    func collect() async -> FeedbackMetadata
}
