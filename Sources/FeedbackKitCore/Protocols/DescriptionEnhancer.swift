import Foundation

/// A protocol for AI-powered description enhancement
public protocol DescriptionEnhancer: Sendable {
    /// Enhance a feedback description using AI
    ///
    /// - Parameter description: The original description text
    /// - Returns: An improved version of the description
    /// - Throws: `FeedbackError` if enhancement fails
    func enhance(_ description: String) async throws -> String
}
