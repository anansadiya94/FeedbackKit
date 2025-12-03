import Foundation

/// A feedback submission containing title, description, and optional attachments
public struct FeedbackItem: Equatable, Sendable {
    /// The title/summary of the feedback
    public let title: String

    /// The detailed description of the feedback
    public let description: String

    /// Optional attachments (screenshots, files, etc.)
    public let attachments: [FeedbackAttachment]

    /// Whether the description was AI-generated
    public let isAIGenerated: Bool

    public init(
        title: String,
        description: String,
        attachments: [FeedbackAttachment] = [],
        isAIGenerated: Bool = false
    ) {
        self.title = title
        self.description = description
        self.attachments = attachments
        self.isAIGenerated = isAIGenerated
    }
}
