import Foundation

/// Errors that can occur during feedback submission or enhancement
public enum FeedbackError: Error, Equatable, LocalizedError {
    /// Configuration is invalid or missing required fields
    case invalidConfiguration(String)

    /// Feedback submission failed
    case submissionFailed(String)

    /// AI enhancement failed
    case enhancementFailed(String)

    /// Attachment is too large
    case attachmentTooLarge(maxSize: Int)

    /// Network error occurred
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .submissionFailed(let message):
            return "Submission failed: \(message)"
        case .enhancementFailed(let message):
            return "Enhancement failed: \(message)"
        case .attachmentTooLarge(let maxSize):
            return "Attachment exceeds maximum size of \(maxSize) bytes"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
