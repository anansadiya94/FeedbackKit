# Basic Example

The simplest way to use FeedbackKit with the NoOp provider.

## What This Example Shows

- Minimal setup with zero configuration
- NoOp provider logs feedback to console
- Perfect for testing UI without submitting anywhere
- Great starting point for integration

## Running This Example

1. Open FeedbackKit package in Xcode
2. Select "BasicExample" scheme
3. Run on simulator or device
4. Tap "Send Feedback" button
5. Fill out the form and submit
6. Check console for output

## Code Highlights

The default `FeedbackView` automatically uses `NoOpProvider`:

```swift
FeedbackView(
    store: Store(initialState: FeedbackFeature.State()) {
        FeedbackFeature()
    }
    // No withDependencies needed - uses NoOpProvider by default
)
```

## Next Steps

- See `JiraExample` for real Jira integration
- See `CustomProviderExample` for custom backends
