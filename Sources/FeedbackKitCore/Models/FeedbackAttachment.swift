import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An attachment to include with feedback (screenshot, image, file, etc.)
public struct FeedbackAttachment: Equatable, Sendable {
    /// The type of attachment
    public enum AttachmentType: Equatable, Sendable {
        #if canImport(UIKit)
        /// An image attachment with compression quality
        case image(UIImage, compressionQuality: CGFloat)
        #endif

        /// A data attachment with MIME type and filename
        case data(Data, mimeType: String, filename: String)
    }

    /// The type and content of the attachment
    public let type: AttachmentType

    /// Optional caption or description for the attachment
    public let caption: String?

    public init(type: AttachmentType, caption: String? = nil) {
        self.type = type
        self.caption = caption
    }

    #if canImport(UIKit)
    /// Create an image attachment from a UIImage
    public static func image(_ image: UIImage, compressionQuality: CGFloat = 0.9, caption: String? = nil) -> FeedbackAttachment {
        FeedbackAttachment(type: .image(image, compressionQuality: compressionQuality), caption: caption)
    }
    #endif

    /// Create a data attachment
    public static func data(_ data: Data, mimeType: String, filename: String, caption: String? = nil) -> FeedbackAttachment {
        FeedbackAttachment(type: .data(data, mimeType: mimeType, filename: filename), caption: caption)
    }
}
