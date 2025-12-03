import Foundation

/// Metadata about the app and device collected when feedback is submitted
public struct FeedbackMetadata: Equatable, Codable, Sendable {
    /// App version (e.g., "1.0.0")
    public let appVersion: String

    /// App build number (e.g., "123")
    public let appBuild: String

    /// Device model (e.g., "iPhone15,2")
    public let deviceModel: String

    /// OS version (e.g., "17.0")
    public let osVersion: String

    /// Locale identifier (e.g., "en_US")
    public let locale: String

    /// Custom key-value pairs for extensibility
    public let customFields: [String: String]

    public init(
        appVersion: String,
        appBuild: String,
        deviceModel: String,
        osVersion: String,
        locale: String,
        customFields: [String: String] = [:]
    ) {
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.locale = locale
        self.customFields = customFields
    }
}
