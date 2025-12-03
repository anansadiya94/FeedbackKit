import Foundation

/// A protocol for submitting feedback to various backends (Jira, custom APIs, etc.)
public protocol FeedbackProvider: Sendable {
    /// Submit feedback with metadata and return a result containing the identifier and URL
    ///
    /// - Parameters:
    ///   - feedback: The feedback item containing title, description, and attachments
    ///   - metadata: Device and app metadata to include with the submission
    /// - Returns: A result containing the feedback identifier and optional URL
    /// - Throws: `FeedbackError` if submission fails
    func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult
}

/// The result of submitting feedback
public struct FeedbackResult: Equatable, Sendable {
    /// Unique identifier for the submitted feedback (e.g., "IOS-1234")
    public let identifier: String

    /// Optional URL to view the feedback (e.g., Jira ticket URL)
    public let url: URL?

    /// Name of the provider that handled the submission
    public let providerName: String

    public init(identifier: String, url: URL?, providerName: String) {
        self.identifier = identifier
        self.url = url
        self.providerName = providerName
    }
}
