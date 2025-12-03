import SwiftUI
import FeedbackKit

@main
struct BasicExampleApp: App {
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
                Text("Basic Example")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This example uses the NoOp provider which logs feedback to the console without submitting anywhere.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Button {
                    showFeedback = true
                } label: {
                    Label("Send Feedback", systemImage: "bubble.left.and.bubble.right")
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
            .sheet(isPresented: $showFeedback) {
                FeedbackView(
                    store: Store(initialState: FeedbackFeature.State()) {
                        FeedbackFeature()
                    }
                    // Using default NoOpProvider - no configuration needed!
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
