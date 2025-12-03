import SwiftUI
import FeedbackKit
import FeedbackKitCore

@main
struct CustomProviderExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Custom Provider Example")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This example shows how to create a custom feedback provider for your own backend.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    ExampleCard(
                        title: "Slack Webhook",
                        description: "Posts feedback to Slack channel"
                    )

                    ExampleCard(
                        title: "Email Backend",
                        description: "Sends feedback via email API"
                    )

                    ExampleCard(
                        title: "Custom REST API",
                        description: "Posts to your own feedback endpoint"
                    )
                }
                .padding(.horizontal)

                Button {
                    showFeedback = true
                } label: {
                    Label("Send to Custom Backend", systemImage: "server.rack")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                Text("Check console for simulated API calls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("FeedbackKit")
            .sheet(isPresented: $showFeedback) {
                FeedbackView(
                    store: Store(initialState: FeedbackFeature.State()) {
                        FeedbackFeature()
                    } withDependencies: {
                        // Using our custom Slack provider
                        $0.feedbackProvider = SlackWebhookProvider(
                            webhookURL: URL(string: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL")!
                        )
                    }
                )
            }
        }
    }
}

// MARK: - Example Card

struct ExampleCard: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Custom Provider Examples

/// Example 1: Slack Webhook Provider
struct SlackWebhookProvider: FeedbackProvider {
    let webhookURL: URL

    func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult {
        print("📤 Sending to Slack webhook...")

        let slackMessage = """
        *New Feedback*
        *Title:* \(feedback.title)
        *Description:* \(feedback.description)

        *Device:* \(metadata.deviceModel)
        *OS:* \(metadata.osVersion)
        *App Version:* \(metadata.appVersion)
        """

        let payload: [String: Any] = [
            "text": slackMessage,
            "username": "FeedbackBot",
            "icon_emoji": ":speech_balloon:"
        ]

        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Simulated for demo - in real app, would make actual request
        print("✅ Would send to Slack: \(slackMessage)")

        return FeedbackResult(
            identifier: "slack-\(UUID().uuidString.prefix(8))",
            url: nil,
            providerName: "Slack"
        )
    }
}

/// Example 2: Email Provider
struct EmailProvider: FeedbackProvider {
    let apiURL: URL
    let apiKey: String

    func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult {
        print("📧 Sending via email...")

        let emailPayload: [String: Any] = [
            "to": "feedback@company.com",
            "subject": "[Feedback] \(feedback.title)",
            "body": """
                \(feedback.description)

                ---
                Device: \(metadata.deviceModel)
                OS: \(metadata.osVersion)
                App: \(metadata.appVersion)
                """
        ]

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: emailPayload)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("✅ Would send email: \(emailPayload)")

        return FeedbackResult(
            identifier: "email-\(UUID().uuidString.prefix(8))",
            url: nil,
            providerName: "Email"
        )
    }
}

/// Example 3: Custom REST API Provider
struct CustomAPIProvider: FeedbackProvider {
    let baseURL: URL
    let authToken: String

    func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult {
        print("🌐 Posting to custom API...")

        let endpoint = baseURL.appendingPathComponent("/api/feedback")

        let payload: [String: Any] = [
            "title": feedback.title,
            "description": feedback.description,
            "metadata": [
                "device": metadata.deviceModel,
                "os": metadata.osVersion,
                "version": metadata.appVersion
            ]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("✅ Would post to API: \(payload)")

        return FeedbackResult(
            identifier: "api-\(UUID().uuidString.prefix(8))",
            url: baseURL.appendingPathComponent("/feedback/\(UUID().uuidString)"),
            providerName: "CustomAPI"
        )
    }
}

#Preview {
    ContentView()
}
