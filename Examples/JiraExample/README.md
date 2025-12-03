# Jira Integration Example

Complete example showing how to integrate with Jira and optionally enhance descriptions with AI.

## What This Example Shows

- Loading configuration from environment variables
- Jira ticket creation with attachments
- Optional AI description enhancement
- Error handling and validation
- Custom field configuration

## Setup

### 1. Set Environment Variables

Edit the scheme (Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables):

**Required:**
- `JIRA_BASE_URL` = `https://your-company.atlassian.net`
- `JIRA_EMAIL` = `your-email@company.com`
- `JIRA_API_TOKEN` = `your-api-token`
- `JIRA_PROJECT_KEY` = `PROJ`

**Optional (for AI):**
- `OPENAI_API_KEY` = `sk-...`

### 2. Get Jira API Token

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Create API token
3. Copy and use as `JIRA_API_TOKEN`

### 3. Run

1. Select "JiraExample" scheme
2. Run on simulator or device
3. Tap "Send Feedback to Jira"
4. Fill out form
5. Submit and check Jira!

## Code Highlights

### Loading from Environment

```swift
let jiraConfig = try JiraConfiguration.fromEnvironment()
```

### Custom Fields

```swift
JiraConfiguration(
    baseURL: URL(string: "https://company.atlassian.net")!,
    email: "your@email.com",
    apiToken: "token",
    projectKey: "PROJ",
    customFields: [
        "customfield_10001": .array(["iOS"]),
        "customfield_10002": .string("Production")
    ]
)
```

### With AI Enhancement

```swift
FeedbackView(
    store: Store(initialState: FeedbackFeature.State()) {
        FeedbackFeature()
    } withDependencies: {
        $0.feedbackProvider = JiraProvider(configuration: jiraConfig)
        $0.descriptionEnhancer = OpenAIEnhancer(configuration: aiConfig)
    }
)
```

## Security Notes

- Never commit API tokens to git
- Use environment variables or keychain
- Consider backend proxy for production
- See main README for security best practices
