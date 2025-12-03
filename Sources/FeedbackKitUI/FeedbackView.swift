import SwiftUI
import ComposableArchitecture
import FeedbackKitCore

public struct FeedbackView: View {
    @Bindable var store: StoreOf<FeedbackFeature>
    @Environment(\.dismiss) private var dismiss
    let theme: FeedbackTheme

    public init(
        store: StoreOf<FeedbackFeature>,
        theme: FeedbackTheme = DefaultFeedbackTheme()
    ) {
        self.store = store
        self.theme = theme
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if store.isSuccess != true {
                            formCard
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }

                        if store.isSuccess == true {
                            successView
                                .padding(.vertical, 32)
                        }

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if store.isSuccess != true {
                        Button("Cancel") {
                            dismiss()
                        }
                        .disabled(store.isSending)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if store.isSending {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Sending...")
                                .font(.subheadline)
                                .foregroundStyle(theme.secondaryTextColor)
                        }
                    } else if store.isSuccess == true {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    } else {
                        Button {
                            store.send(.sendFeedback)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "paperplane.fill")
                                Text("Send")
                            }
                        }
                        .fontWeight(.semibold)
                        .disabled(store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { store.error != nil },
                    set: { _ in store.send(.clearError) }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = store.error {
                    Text(error)
                }
            }
            .sheet(isPresented: $store.showShareSheet) {
                if let url = store.lastTicketResult?.url {
                    ShareSheet(items: [url])
                } else if let identifier = store.lastTicketResult?.identifier {
                    ShareSheet(items: [identifier])
                }
            }
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 0) {
            // Title Input
            VStack(alignment: .leading, spacing: 12) {
                Label("Title", systemImage: "text.cursor")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.secondaryTextColor)

                TextField("Enter a title for the issue", text: $store.title)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color(.separator), lineWidth: 0.5)
                    )
            }
            .padding(16)

            Divider()
                .padding(.horizontal, 16)

            // Description Input
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.secondaryTextColor)

                    Spacer()

                    // Markdown Preview Toggle
                    if !store.message.isEmpty {
                        Button {
                            store.send(.toggleMarkdownPreview)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: store.showMarkdownPreview ? "doc.plaintext" : "doc.richtext")
                                Text(store.showMarkdownPreview ? "Edit" : "Preview")
                            }
                            .font(.caption)
                            .foregroundStyle(theme.primaryColor)
                        }
                    }
                }

                if store.showMarkdownPreview {
                    // Markdown Preview
                    ScrollView {
                        Text(.init(store.message))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                    }
                    .frame(minHeight: 120)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color(.separator), lineWidth: 0.5)
                    )
                } else {
                    // Text Editor
                    ZStack(alignment: .topLeading) {
                        if store.message.isEmpty {
                            Text("Describe the issue or feedback...")
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                        }

                        TextEditor(text: $store.message)
                            .autocorrectionDisabled(true)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color(.separator), lineWidth: 0.5)
                            )
                    }
                }

                // AI Button
                Button {
                    store.send(.improveDescription)
                } label: {
                    HStack(spacing: 6) {
                        if store.isImproving {
                            ProgressView()
                                .controlSize(.small)
                            Text("Improving...")
                        } else if store.isAIGenerated {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Generated by AI")
                        } else {
                            Image(systemName: "sparkles")
                            Text("Improve with AI")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: store.isAIGenerated ? [Color.green, Color.green] : [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: (store.isAIGenerated ? Color.green : Color.purple).opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(store.message.isEmpty || store.isImproving || store.isSending || store.isAIGenerated)
                .opacity(store.message.isEmpty || store.isAIGenerated ? 0.7 : 1.0)
            }
            .padding(16)

            // Screenshot Preview
            if let screenshot = store.screenshot {
                Divider()
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Label("Screenshot", systemImage: "photo")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.secondaryTextColor)

                    Image(uiImage: screenshot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                .strokeBorder(Color(.separator), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(16)
            }
        }
        .background(theme.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: store.isSuccess)

                Text("Feedback Submitted!")
                    .font(theme.titleFont)

                if let result = store.lastTicketResult {
                    Text("Your feedback has been sent to \(result.providerName).")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryTextColor)
                        .multilineTextAlignment(.center)

                    Text(result.identifier)
                        .font(.caption.monospaced())
                        .foregroundStyle(theme.secondaryTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.cardColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(.vertical, 24)

            // Action Buttons
            VStack(spacing: 12) {
                // Copy Button
                Button {
                    store.send(.copyTicketLink)
                } label: {
                    HStack {
                        Image(systemName: store.showCopiedConfirmation ? "checkmark" : "doc.on.doc")
                        Text(store.showCopiedConfirmation ? "Copied!" : "Copy Link")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.cardColor)
                    .foregroundStyle(store.showCopiedConfirmation ? .green : theme.textColor)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .strokeBorder(store.showCopiedConfirmation ? Color.green : Color(.separator), lineWidth: 1)
                    )
                }
                .animation(.easeInOut(duration: 0.2), value: store.showCopiedConfirmation)

                // Share Button
                Button {
                    store.send(.toggleShareSheet)
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Ticket")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.cardColor)
                    .foregroundStyle(theme.textColor)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .strokeBorder(Color(.separator), lineWidth: 1)
                    )
                }

                // View Button
                if let url = store.lastTicketResult?.url {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("View Ticket")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.primaryColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Previews

#Preview("Empty Form") {
    FeedbackView(
        store: Store(initialState: FeedbackFeature.State()) {
            FeedbackFeature()
        }
    )
}

#Preview("Success State") {
    FeedbackView(
        store: Store(
            initialState: FeedbackFeature.State(
                isSuccess: true,
                lastTicketResult: FeedbackResult(
                    identifier: "PREVIEW-1234",
                    url: URL(string: "https://example.com/ticket/PREVIEW-1234"),
                    providerName: "Preview"
                )
            )
        ) {
            FeedbackFeature()
        }
    )
}
