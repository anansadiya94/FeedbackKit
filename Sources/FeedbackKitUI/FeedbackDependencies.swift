import Dependencies
import FeedbackKitCore
import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Dependency Values Extensions

extension DependencyValues {
    public var feedbackProvider: any FeedbackProvider {
        get { self[FeedbackProviderKey.self] }
        set { self[FeedbackProviderKey.self] = newValue }
    }

    public var descriptionEnhancer: any DescriptionEnhancer {
        get { self[DescriptionEnhancerKey.self] }
        set { self[DescriptionEnhancerKey.self] = newValue }
    }

    public var metadataCollector: MetadataCollector {
        get { self[MetadataCollectorKey.self] }
        set { self[MetadataCollectorKey.self] = newValue }
    }

    public var screenshotCapture: ScreenshotCapture {
        get { self[ScreenshotCaptureKey.self] }
        set { self[ScreenshotCaptureKey.self] = newValue }
    }
}

// MARK: - Dependency Keys

private enum FeedbackProviderKey: DependencyKey {
    static let liveValue: any FeedbackProvider = NoOpProvider()
    static let testValue: any FeedbackProvider = NoOpProvider()
    static let previewValue: any FeedbackProvider = PreviewProvider()
}

private enum DescriptionEnhancerKey: DependencyKey {
    static let liveValue: any DescriptionEnhancer = NoOpEnhancer()
    static let testValue: any DescriptionEnhancer = NoOpEnhancer()
    static let previewValue: any DescriptionEnhancer = PreviewEnhancer()
}

private enum MetadataCollectorKey: DependencyKey {
    static let liveValue: MetadataCollector = DefaultMetadataCollector()
    static let testValue: MetadataCollector = DefaultMetadataCollector()
    static let previewValue: MetadataCollector = PreviewMetadataCollector()
}

private enum ScreenshotCaptureKey: DependencyKey {
    static let liveValue: ScreenshotCapture = ScreenshotCapture()
    static let testValue: ScreenshotCapture = ScreenshotCapture()
    static let previewValue: ScreenshotCapture = ScreenshotCapture()
}

// MARK: - No-Op Provider

/// A feedback provider that does nothing (for testing/preview)
public struct NoOpProvider: FeedbackProvider {
    public init() {}

    public func submit(_ feedback: FeedbackItem, metadata: FeedbackMetadata) async throws -> FeedbackResult {
        print("📝 NoOp Provider: \(feedback.title)")
        print("   Description: \(feedback.description)")
        print("   Attachments: \(feedback.attachments.count)")
        print("   Metadata: \(metadata.appVersion) on \(metadata.deviceModel)")

        return FeedbackResult(
            identifier: "NOOP-\(UUID().uuidString.prefix(8))",
            url: nil,
            providerName: "NoOp"
        )
    }
}

/// A feedback provider for SwiftUI previews
struct PreviewProvider: FeedbackProvider {
    func submit(_ feedback: FeedbackItem, metadata: FeedbackMetadata) async throws -> FeedbackResult {
        try await Task.sleep(for: .seconds(1))
        return FeedbackResult(
            identifier: "PREVIEW-1234",
            url: URL(string: "https://example.com/ticket/PREVIEW-1234"),
            providerName: "Preview"
        )
    }
}

// MARK: - No-Op Enhancer

/// A description enhancer that does nothing (for testing/preview)
public struct NoOpEnhancer: DescriptionEnhancer {
    public init() {}

    public func enhance(_ description: String) async throws -> String {
        print("✨ NoOp Enhancer: Not enhancing description")
        return description
    }
}

/// A description enhancer for SwiftUI previews
struct PreviewEnhancer: DescriptionEnhancer {
    func enhance(_ description: String) async throws -> String {
        try await Task.sleep(for: .seconds(1))
        return "Enhanced: \(description)\n\nThis description has been improved by AI to provide more clarity and technical details."
    }
}

// MARK: - Preview Metadata Collector

struct PreviewMetadataCollector: MetadataCollector {
    func collect() async -> FeedbackMetadata {
        FeedbackMetadata(
            appVersion: "1.0.0",
            appBuild: "123",
            deviceModel: "iPhone 15 Pro",
            osVersion: "17.0",
            locale: "en_US",
            customFields: ["environment": "Development"]
        )
    }
}
