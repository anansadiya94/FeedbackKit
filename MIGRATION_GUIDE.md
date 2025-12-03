# Migration Guide: Integrating FeedbackKit into SFG Project

This guide explains how to integrate FeedbackKit into your existing SFG project and migrate away from the original `JiraFeedback.swift` file.

## Overview

The original `JiraFeedback.swift` file contained:
- Hardcoded Jira credentials (lines 53-54)
- Hardcoded OpenAI API key (line 205)
- Shutterfly-specific dependencies (SFGNetwork, SFGUserDefaultsClient)

FeedbackKit removes all of these and provides a clean, reusable API.

## Step 1: Add FeedbackKit as Dependency

### Option A: Local Development (Recommended Initially)

In `/Users/anan.sadiya/Developer/SFG2/SFG/SFG/Package.swift`:

```swift
dependencies: [
    // ... existing dependencies
    .package(path: "../../FeedbackKit"),  // Local path during development
]
```

### Option B: GitHub URL (After Publishing)

```swift
dependencies: [
    .package(url: "https://github.com/yourorg/FeedbackKit", from: "1.0.0")
]
```

Then add to your target dependencies:

```swift
.target(
    name: "SFGDebugCommonScreen",
    dependencies: [
        // ... existing dependencies
        .product(name: "FeedbackKit", package: "FeedbackKit"),
        .product(name: "FeedbackKitJira", package: "FeedbackKit"),
        .product(name: "FeedbackKitAI", package: "FeedbackKit"),
    ]
)
```

## Step 2: Create Integration File

Create a new file: `SFGDebugCommonScreen/FeedbackKitIntegration.swift`

```swift
import FeedbackKit
import FeedbackKitJira
import FeedbackKitAI
import SFGUserDefaultsClient
import SFGNetwork

// MARK: - Jira Configuration

extension JiraConfiguration {
    /// Shutterfly's Jira configuration
    static var shutterfly: JiraConfiguration {
        JiraConfiguration(
            baseURL: URL(string: "https://snapfish-llc.atlassian.net")!,
            email: ProcessInfo.processInfo.environment["JIRA_EMAIL"] ?? "",
            apiToken: ProcessInfo.processInfo.environment["JIRA_API_TOKEN"] ?? "",
            projectKey: "IOS",
            issueType: "Bug",
            customFields: [
                "customfield_17223": .array(["Production"]),  // Environment
                "customfield_16300": .array(["iOS"])           // Platform
            ]
        )
    }
}

// MARK: - AI Configuration

extension AIConfiguration {
    /// Shutterfly's OpenAI configuration
    static var shutterfly: AIConfiguration {
        .openAI(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")
    }
}

// MARK: - Custom Metadata Collector

/// Custom metadata collector that includes SFG-specific information
struct SFGMetadataCollector: MetadataCollector {
    func collect() async -> FeedbackMetadata {
        let environment = SFGRequest.Environment(
            rawValue: SFGUserDefaultsClient.standard.value(key: .serverEnvironmentKey)
        )

        let bundle = Bundle.main

        return FeedbackMetadata(
            appVersion: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            appBuild: bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            locale: Locale.current.identifier,
            customFields: [
                "environment": environment.readableDescription,
                "route": "TBD"  // TODO: Add actual route tracking
            ]
        )
    }
}

// MARK: - Convenience Factory

struct SFGFeedbackKit {
    /// Create a pre-configured FeedbackView for SFG
    static func makeFeedbackView() -> FeedbackView {
        FeedbackView(
            store: Store(initialState: FeedbackFeature.State()) {
                FeedbackFeature()
            } withDependencies: {
                $0.feedbackProvider = JiraProvider(configuration: .shutterfly)
                $0.descriptionEnhancer = OpenAIEnhancer(configuration: .shutterfly)
                $0.metadataCollector = SFGMetadataCollector()
            }
        )
    }
}
```

## Step 3: Update Debug Menu

In your debug menu (e.g., `DebugCommonCategory.swift`), replace usage of `SFGJiraFeedbackView`:

### Before:
```swift
import SFGDebugCommonScreen

// Somewhere in your debug settings
.navigationDestination {
    SFGJiraFeedbackView(
        store: Store(initialState: SFGJiraFeedbackFeature.State()) {
            SFGJiraFeedbackFeature()
        }
    )
}
```

### After:
```swift
import FeedbackKit

// Somewhere in your debug settings
.navigationDestination {
    SFGFeedbackKit.makeFeedbackView()
}
```

## Step 4: Set Environment Variables

### Development (Xcode Schemes)

1. Edit your scheme (Product → Scheme → Edit Scheme)
2. Go to Run → Arguments → Environment Variables
3. Add:
   - `JIRA_EMAIL` = `your-email@shutterfly.com`
   - `JIRA_API_TOKEN` = `your-jira-token`
   - `OPENAI_API_KEY` = `your-openai-key`

### CI/CD

Add to your CI/CD secrets:
- `JIRA_EMAIL`
- `JIRA_API_TOKEN`
- `OPENAI_API_KEY`

### Production (Backend Proxy)

For production, consider creating a backend proxy that stores credentials securely:

```swift
struct ProxyFeedbackProvider: FeedbackProvider {
    let backendURL: URL

    func submit(_ feedback: FeedbackItem, metadata: FeedbackMetadata) async throws -> FeedbackResult {
        // Send to your backend
        // Backend calls Jira with stored credentials
        // This way, API keys never leave your server
    }
}
```

## Step 5: Deprecate Old File (Optional)

Add deprecation warning to `JiraFeedback.swift`:

```swift
@available(*, deprecated, message: "Use FeedbackKit instead. See MIGRATION_GUIDE.md")
struct JiraClient {
    // ... existing code
}

@available(*, deprecated, message: "Use FeedbackKit instead. See MIGRATION_GUIDE.md")
struct ChatGPTClient {
    // ... existing code
}

@available(*, deprecated, message: "Use FeedbackKit instead. See MIGRATION_GUIDE.md")
@Reducer
public struct SFGJiraFeedbackFeature {
    // ... existing code
}

@available(*, deprecated, message: "Use FeedbackKit instead. See MIGRATION_GUIDE.md")
public struct SFGJiraFeedbackView: View {
    // ... existing code
}
```

## Step 6: Test the Migration

1. Build the project: `swift build`
2. Run on simulator/device
3. Open debug menu
4. Trigger feedback form
5. Submit a test ticket
6. Verify it appears in Jira

## Rollback Plan

If issues arise, you can quickly rollback:

1. Comment out FeedbackKit in Package.swift
2. Remove deprecation warnings from JiraFeedback.swift
3. Restore old debug menu code
4. File issues at: https://github.com/yourorg/FeedbackKit/issues

## Timeline

- **Week 1**: Add FeedbackKit as local dependency, test locally
- **Week 2**: Update debug menu, test thoroughly
- **Week 3**: Deprecate old file, monitor for issues
- **Week 4**: Remove old file completely (optional)

## Benefits After Migration

✅ No hardcoded credentials in source code
✅ Easy to update API keys without code changes
✅ Modular - can swap providers easily
✅ Themeable UI
✅ Better testability with dependency injection
✅ Reusable across multiple projects

## Support

For questions or issues:
- Check the main README.md
- Review the plan file: `~/.claude/plans/cryptic-floating-journal.md`
- Open an issue on GitHub
