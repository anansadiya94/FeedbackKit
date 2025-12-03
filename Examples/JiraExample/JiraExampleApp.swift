import SwiftUI
import FeedbackKit
import FeedbackKitJira
import FeedbackKitAI

@main
struct JiraExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showFeedback = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Jira Integration Example")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This example submits feedback directly to Jira with optional AI enhancement.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Required Environment Variables:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        EnvVarRow(name: "JIRA_BASE_URL", example: "https://company.atlassian.net")
                        EnvVarRow(name: "JIRA_EMAIL", example: "your@email.com")
                        EnvVarRow(name: "JIRA_API_TOKEN", example: "your-api-token")
                        EnvVarRow(name: "JIRA_PROJECT_KEY", example: "PROJ")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text("Optional for AI:")
                        .font(.headline)
                        .padding(.top, 8)

                    EnvVarRow(name: "OPENAI_API_KEY", example: "sk-...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Button {
                    do {
                        // Verify configuration before showing
                        _ = try makeJiraConfiguration()
                        showFeedback = true
                    } catch {
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                } label: {
                    Label("Send Feedback to Jira", systemImage: "paperplane")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .navigationTitle("FeedbackKit")
            .alert("Configuration Error", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showFeedback) {
                makeFeedbackView()
            }
        }
    }

    // MARK: - Configuration

    private func makeJiraConfiguration() throws -> JiraConfiguration {
        try JiraConfiguration.fromEnvironment()
    }

    private func makeAIConfiguration() -> AIConfiguration? {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
              !apiKey.isEmpty else {
            return nil
        }
        return .openAI(apiKey: apiKey)
    }

    private func makeFeedbackView() -> FeedbackView {
        do {
            let jiraConfig = try makeJiraConfiguration()
            let aiConfig = makeAIConfiguration()

            return FeedbackView(
                store: Store(initialState: FeedbackFeature.State()) {
                    FeedbackFeature()
                } withDependencies: {
                    $0.feedbackProvider = JiraProvider(configuration: jiraConfig)

                    if let aiConfig = aiConfig {
                        $0.descriptionEnhancer = OpenAIEnhancer(configuration: aiConfig)
                    }
                }
            )
        } catch {
            // Fallback to NoOp if configuration fails
            return FeedbackView(
                store: Store(initialState: FeedbackFeature.State()) {
                    FeedbackFeature()
                }
            )
        }
    }
}

// MARK: - Helper Views

struct EnvVarRow: View {
    let name: String
    let example: String

    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.medium)
                .monospaced()

            Text("=")
                .foregroundStyle(.tertiary)

            Text(example)
                .foregroundStyle(.tertiary)
                .italic()
        }
    }
}

#Preview {
    ContentView()
}
