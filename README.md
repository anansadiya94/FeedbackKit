# FeedbackKit

A modern, modular iOS SDK for collecting and submitting user feedback with support for Jira, custom backends, and optional AI-powered description enhancement.

## Features

- 🎯 **Protocol-based architecture** - Easy to extend with custom providers
- 🔌 **Multiple providers** - Built-in support for Jira, with the ability to add custom backends
- 🤖 **Optional AI enhancement** - Improve feedback descriptions with OpenAI GPT or Anthropic Claude
- 🎨 **SwiftUI + TCA** - Beautiful, reactive UI built with Composable Architecture
- 📸 **Screenshot capture** - Automatically attach screenshots to feedback
- 🧪 **Full test coverage** - Comprehensive unit tests for all components
- 🔒 **Secure by default** - No hardcoded API keys, environment-based configuration
- 🎨 **Themeable UI** - Customize colors, fonts, and styling

## Installation

### Swift Package Manager

Add FeedbackKit to your project using Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/yourorg/FeedbackKit`
3. Select the modules you need:
   - `FeedbackKit` - **Recommended** - All-in-one package (includes Core, UI, Jira, and AI)
   - `FeedbackKitCore` - Just the protocols and models (for custom implementations)
   - `FeedbackKitJira` - Only Jira integration
   - `FeedbackKitAI` - Only AI enhancement (OpenAI, Claude)
   - `FeedbackKitUI` - Only SwiftUI views and TCA features

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourorg/FeedbackKit", from: "1.0.0")
]
```

## Quick Start

> **Note:** Simply `import FeedbackKit` to access all features (Core, UI, Jira, and AI). You no longer need to import multiple packages! Individual modules are still available if you prefer granular imports.

### Basic Usage (NoOp Provider)

The simplest way to get started is with the NoOp provider, which logs feedback to the console:

```swift
import SwiftUI
import FeedbackKit

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        Button("Send Feedback") {
            showFeedback = true
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView(
                store: Store(initialState: FeedbackFeature.State()) {
                    FeedbackFeature()
                }
            )
        }
    }
}
```

### Jira Integration

To submit feedback to Jira, configure the Jira provider with your credentials:

```swift
import FeedbackKit

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        Button("Send Feedback") {
            showFeedback = true
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView(
                store: Store(initialState: FeedbackFeature.State()) {
                    FeedbackFeature()
                } withDependencies: {
                    $0.feedbackProvider = makeJiraProvider()
                }
            )
        }
    }

    func makeJiraProvider() -> JiraProvider {
        let config = JiraConfiguration(
            baseURL: URL(string: "https://your-company.atlassian.net")!,
            email: ProcessInfo.processInfo.environment["JIRA_EMAIL"]!,
            apiToken: ProcessInfo.processInfo.environment["JIRA_API_TOKEN"]!,
            projectKey: "PROJ",
            issueType: "Bug"
        )
        return JiraProvider(configuration: config)
    }
}
```

### Jira with AI Enhancement

Add AI-powered description improvement:

```swift
import FeedbackKit

FeedbackView(
    store: Store(initialState: FeedbackFeature.State()) {
        FeedbackFeature()
    } withDependencies: {
        $0.feedbackProvider = JiraProvider(configuration: jiraConfig)
        $0.descriptionEnhancer = OpenAIEnhancer(
            configuration: .openAI(
                apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!
            )
        )
    }
)
```

### Claude AI Support

Use Anthropic Claude instead of OpenAI:

```swift
$0.descriptionEnhancer = AnthropicEnhancer(
    configuration: .anthropic(
        apiKey: ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]!
    )
)
```

## Custom Feedback Provider

Create your own feedback backend by implementing `FeedbackProvider`:

```swift
import FeedbackKitCore

struct SlackProvider: FeedbackProvider {
    let webhookURL: URL

    func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult {
        let payload = [
            "text": """
            *\(feedback.title)*
            \(feedback.description)

            Device: \(metadata.deviceModel)
            Version: \(metadata.appVersion)
            """
        ]

        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw FeedbackError.submissionFailed("Slack webhook failed")
        }

        return FeedbackResult(
            identifier: UUID().uuidString,
            url: nil,
            providerName: "Slack"
        )
    }
}

// Usage:
$0.feedbackProvider = SlackProvider(
    webhookURL: URL(string: "https://hooks.slack.com/...")!
)
```

## Configuration

### Environment Variables

The recommended approach for API keys is environment variables:

```bash
# Jira
export JIRA_BASE_URL="https://your-company.atlassian.net"
export JIRA_EMAIL="your-email@company.com"
export JIRA_API_TOKEN="your-api-token"
export JIRA_PROJECT_KEY="PROJ"

# OpenAI
export OPENAI_API_KEY="sk-..."

# Anthropic
export ANTHROPIC_API_KEY="sk-ant-..."
```

Then load from environment:

```swift
let jiraConfig = try JiraConfiguration.fromEnvironment()
let aiConfig = try AIConfiguration.fromEnvironment()
```

### Custom Metadata

Add custom metadata fields to your feedback:

```swift
struct CustomMetadataCollector: MetadataCollector {
    func collect() async -> FeedbackMetadata {
        let default = await DefaultMetadataCollector().collect()

        return FeedbackMetadata(
            appVersion: default.appVersion,
            appBuild: default.appBuild,
            deviceModel: default.deviceModel,
            osVersion: default.osVersion,
            locale: default.locale,
            customFields: [
                "environment": "Production",
                "userId": UserDefaults.standard.string(forKey: "userId") ?? "Unknown",
                "subscription": "Premium"
            ]
        )
    }
}

// Usage:
$0.metadataCollector = CustomMetadataCollector()
```

### Theming

Customize the UI appearance:

```swift
struct MyTheme: FeedbackTheme {
    var primaryColor: Color { .purple }
    var backgroundColor: Color { .black }
    var cardColor: Color { Color(.systemGray6) }
    var textColor: Color { .white }
    var secondaryTextColor: Color { .gray }
    var cornerRadius: CGFloat { 16 }
    var buttonFont: Font { .headline }
    var titleFont: Font { .largeTitle.bold() }
    var bodyFont: Font { .body }
}

FeedbackView(
    store: ...,
    theme: MyTheme()
)
```

## Security Best Practices

### Never Commit API Keys!

Add to `.gitignore`:

```
.env
Config.plist
Secrets/
```

### Recommended Approaches

1. **Environment Variables** (Development)
   ```swift
   ProcessInfo.processInfo.environment["API_KEY"]
   ```

2. **Xcode Configuration Files** (CI/CD)
   - Use `.xcconfig` files
   - Set in Xcode schemes

3. **Backend Proxy** (Production - Most Secure)
   - Client calls your backend
   - Backend stores credentials securely
   - Backend proxies to Jira/OpenAI

Example backend proxy:

```swift
struct ProxyProvider: FeedbackProvider {
    let backendURL: URL

    func submit(_ feedback: FeedbackItem, metadata: FeedbackMetadata) async throws -> FeedbackResult {
        // Send to your backend, which then calls Jira/AI APIs
        // This way, API keys never leave your server
    }
}
```

## Architecture

FeedbackKit uses a protocol-based architecture that separates concerns:

```
┌─────────────────────────────────────┐
│       FeedbackKitUI (Views)         │
│   ┌─────────────────────────────┐   │
│   │     FeedbackView            │   │
│   │     FeedbackFeature (TCA)   │   │
│   └─────────────────────────────┘   │
└─────────────────┬───────────────────┘
                  │ depends on
┌─────────────────▼───────────────────┐
│     FeedbackKitCore (Protocols)     │
│   ┌─────────────────────────────┐   │
│   │  FeedbackProvider           │   │
│   │  DescriptionEnhancer        │   │
│   │  MetadataCollector          │   │
│   └─────────────────────────────┘   │
└─────────────────┬───────────────────┘
                  │ implemented by
        ┌─────────┴──────────┐
        ▼                    ▼
┌──────────────--─┐    ┌─-───----──────────┐
│ FeedbackKitJira │    │ FeedbackKitAI     │
│  JiraProvider   │    │ OpenAIEnhancer    │
│                 │    │ AnthropicEnhancer │
└──────────────-─-┘    └─----─────────────-┘
```

## Testing

FeedbackKit includes test helpers for easy testing:

```swift
import XCTest
import ComposableArchitecture
import FeedbackKit

@Test func testSubmitFeedback() async {
    let store = TestStore(initialState: FeedbackFeature.State()) {
        FeedbackFeature()
    } withDependencies: {
        $0.feedbackProvider = MockProvider()
        $0.metadataCollector = MockMetadataCollector()
    }

    await store.send(.sendFeedback) {
        $0.isSending = true
    }

    await store.receive(.feedbackResponse(.success(mockResult))) {
        $0.isSending = false
        $0.isSuccess = true
    }
}
```

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Dependencies

- [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) (1.18.0+)
- [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) (1.8.0+)

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Created for Shutterfly's hackday and transformed into a reusable SDK.

## Support

For issues and questions:
- Open an issue on [GitHub](https://github.com/yourorg/FeedbackKit/issues)
- Check the [documentation](https://github.com/yourorg/FeedbackKit/wiki)
