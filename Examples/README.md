# FeedbackKit Examples

This directory contains example projects demonstrating different ways to use FeedbackKit.

## Available Examples

### 1. BasicExample
**Difficulty:** Beginner
**What it shows:** Minimal setup with NoOp provider

The simplest possible integration. Uses the default `NoOpProvider` which logs feedback to console. Perfect for:
- Testing the UI
- Learning the API
- Starting point for your integration

[View BasicExample →](./BasicExample/)

### 2. JiraExample
**Difficulty:** Intermediate
**What it shows:** Complete Jira integration with AI enhancement

Full-featured example showing:
- Jira ticket creation
- Screenshot attachments
- OpenAI description enhancement
- Environment-based configuration
- Custom field mapping

[View JiraExample →](./JiraExample/)

### 3. CustomProviderExample
**Difficulty:** Advanced
**What it shows:** Creating custom feedback providers

Learn how to integrate with your own backend:
- Slack webhook integration
- Email API integration
- Custom REST API integration
- Attachment handling
- Error handling patterns

[View CustomProviderExample →](./CustomProviderExample/)

## Running the Examples

### Option A: Open in Xcode

1. Open `FeedbackKit` package in Xcode
2. Select an example scheme from the scheme selector
3. Run on simulator or device

### Option B: Command Line

```bash
cd ~/Developer/FeedbackKit
swift run BasicExample        # Runs basic example
swift run JiraExample          # Runs Jira example
swift run CustomProviderExample # Runs custom provider example
```

## What to Try

1. **Start with BasicExample**
   - See the UI in action
   - No configuration needed
   - Perfect for understanding the flow

2. **Move to JiraExample**
   - Set up real Jira integration
   - Test AI enhancement
   - Learn configuration patterns

3. **Explore CustomProviderExample**
   - See three different custom providers
   - Learn how to integrate your backend
   - Understand the protocol requirements

## Common Questions

**Q: Can I use these in production?**
A: BasicExample and CustomProviderExample are demos. JiraExample is production-ready once you add proper credential management (keychain, backend proxy, etc.).

**Q: How do I combine providers?**
A: Create a composite provider:
```swift
struct MultiProvider: FeedbackProvider {
    let providers: [FeedbackProvider]

    func submit(_ feedback: FeedbackItem, metadata: FeedbackMetadata) async throws -> FeedbackResult {
        // Submit to all providers
        try await withThrowingTaskGroup(of: FeedbackResult.self) { group in
            for provider in providers {
                group.addTask {
                    try await provider.submit(feedback, metadata: metadata)
                }
            }
            // Return first result
            return try await group.next()!
        }
    }
}
```

**Q: Can I customize the UI?**
A: Yes! Use the theming system:
```swift
struct MyTheme: FeedbackTheme {
    var primaryColor: Color { .purple }
    // ... customize other properties
}

FeedbackView(store: ..., theme: MyTheme())
```

## Need Help?

- Check the main [README.md](../README.md)
- Review the [MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md)
- Open an issue on GitHub
