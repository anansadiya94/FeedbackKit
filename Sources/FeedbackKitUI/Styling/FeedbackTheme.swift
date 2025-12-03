import SwiftUI

/// Protocol for customizing the appearance of feedback UI
public protocol FeedbackTheme {
    var primaryColor: Color { get }
    var backgroundColor: Color { get }
    var cardColor: Color { get }
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var cornerRadius: CGFloat { get }
    var buttonFont: Font { get }
    var titleFont: Font { get }
    var bodyFont: Font { get }
}

/// Default theme matching iOS system colors
public struct DefaultFeedbackTheme: FeedbackTheme {
    public init() {}

    public var primaryColor: Color { .blue }
    public var backgroundColor: Color { Color(.systemGroupedBackground) }
    public var cardColor: Color { Color(.secondarySystemGroupedBackground) }
    public var textColor: Color { .primary }
    public var secondaryTextColor: Color { .secondary }
    public var cornerRadius: CGFloat { 12 }
    public var buttonFont: Font { .subheadline.weight(.medium) }
    public var titleFont: Font { .title2.weight(.bold) }
    public var bodyFont: Font { .body }
}
