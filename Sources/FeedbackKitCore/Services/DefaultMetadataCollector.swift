import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Default implementation of MetadataCollector that gathers standard app and device info
public struct DefaultMetadataCollector: MetadataCollector {
    public init() {}

    public func collect() async -> FeedbackMetadata {
        let bundle = Bundle.main

        let appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        #if canImport(UIKit)
        let deviceModel = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        #else
        let deviceModel = "Mac"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        #endif

        let locale = Locale.current.identifier

        return FeedbackMetadata(
            appVersion: appVersion,
            appBuild: appBuild,
            deviceModel: deviceModel,
            osVersion: osVersion,
            locale: locale,
            customFields: [:]
        )
    }
}
