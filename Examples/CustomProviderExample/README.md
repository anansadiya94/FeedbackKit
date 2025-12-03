# Custom Provider Example

Learn how to create custom feedback providers for any backend.

## What This Example Shows

- Implementing `FeedbackProvider` protocol
- Three complete examples:
  1. Slack webhook integration
  2. Email API integration
  3. Custom REST API integration
- Handling attachments
- Error handling
- Return value construction

## Creating a Custom Provider

### Step 1: Implement Protocol

```swift
import FeedbackKitCore

struct MyProvider: FeedbackProvider {
    func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult {
        // Your implementation here
    }
}
```

### Step 2: Make API Call

```swift
let endpoint = baseURL.appendingPathComponent("/feedback")

let payload: [String: Any] = [
    "title": feedback.title,
    "description": feedback.description,
    "device": metadata.deviceModel
]

var request = URLRequest(url: endpoint)
request.httpMethod = "POST"
request.httpBody = try JSONSerialization.data(withJSONObject: payload)

let (data, response) = try await URLSession.shared.data(for: request)
```

### Step 3: Return Result

```swift
return FeedbackResult(
    identifier: "FB-1234",  // Your ticket ID
    url: URL(string: "https://your-system.com/tickets/1234"),
    providerName: "MySystem"
)
```

### Step 4: Use It

```swift
FeedbackView(
    store: Store(initialState: FeedbackFeature.State()) {
        FeedbackFeature()
    } withDependencies: {
        $0.feedbackProvider = MyProvider(...)
    }
)
```

## Handling Attachments

```swift
for attachment in feedback.attachments {
    switch attachment.type {
    case .image(let image, let quality):
        let imageData = image.jpegData(compressionQuality: quality)
        // Upload image data

    case .data(let data, let mimeType, let filename):
        // Upload generic data
    }
}
```

## Error Handling

```swift
guard let http = response as? HTTPURLResponse,
      (200..<300).contains(http.statusCode) else {
    throw FeedbackError.submissionFailed("API returned error")
}
```

## Real-World Use Cases

1. **Internal ticketing system** - Post to your company's issue tracker
2. **Customer support platform** - Zendesk, Intercom, etc.
3. **Analytics platform** - Track feedback as events
4. **Email/notification** - Send feedback via email or push
5. **Database** - Store directly in your database
6. **Multiple destinations** - Fan out to multiple systems

## Tips

- Use `async/await` for network calls
- Throw `FeedbackError` for consistent error messages
- Include metadata in your submissions
- Return a meaningful URL if available
- Log for debugging
- Consider retry logic for transient failures
