import ComposableArchitecture
import FeedbackKitCore
import Foundation
#if canImport(UIKit)
import UIKit
#endif

@Reducer
public struct FeedbackFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var title = ""
        public var message = ""
        public var isSending = false
        public var isImproving = false
        public var isAIGenerated = false
        public var showMarkdownPreview = false
        public var isSuccess: Bool? = nil
        public var lastTicketResult: FeedbackResult?
        public var error: String?
        public var screenshot: UIImage?
        public var showShareSheet = false
        public var showCopiedConfirmation = false

        public init(
            title: String = "",
            message: String = "",
            isSending: Bool = false,
            isImproving: Bool = false,
            isAIGenerated: Bool = false,
            showMarkdownPreview: Bool = false,
            isSuccess: Bool? = nil,
            lastTicketResult: FeedbackResult? = nil,
            error: String? = nil,
            screenshot: UIImage? = nil,
            showShareSheet: Bool = false,
            showCopiedConfirmation: Bool = false
        ) {
            self.title = title
            self.message = message
            self.isSending = isSending
            self.isImproving = isImproving
            self.isAIGenerated = isAIGenerated
            self.showMarkdownPreview = showMarkdownPreview
            self.isSuccess = isSuccess
            self.lastTicketResult = lastTicketResult
            self.error = error
            self.screenshot = screenshot
            self.showShareSheet = showShareSheet
            self.showCopiedConfirmation = showCopiedConfirmation
        }
    }

    @CasePathable
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case messageChanged(String)
        case sendFeedback
        case feedbackResponse(Result<FeedbackResult, Error>)
        case improveDescription
        case improveDescriptionResponse(Result<String, Error>)
        case toggleMarkdownPreview
        case clearError
        case copyTicketLink
        case toggleShareSheet
        case hideCopiedConfirmation
        case captureScreenshot
        case screenshotCaptured(UIImage?)
    }

    @Dependency(\.feedbackProvider) var feedbackProvider
    @Dependency(\.descriptionEnhancer) var descriptionEnhancer
    @Dependency(\.metadataCollector) var metadataCollector
    @Dependency(\.screenshotCapture) var screenshotCapture

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case let .messageChanged(text):
                state.message = text
                return .none

            case .sendFeedback:
                state.isSending = true
                state.error = nil

                let feedback = FeedbackItem(
                    title: state.title,
                    description: state.message.isEmpty ? "No description provided" : state.message,
                    attachments: state.screenshot.map { [.image($0)] } ?? [],
                    isAIGenerated: state.isAIGenerated
                )

                return .run { send in
                    let metadata = await metadataCollector.collect()
                    let result = await Result {
                        try await feedbackProvider.submit(feedback, metadata: metadata)
                    }
                    await send(.feedbackResponse(result))
                }

            case let .feedbackResponse(.success(result)):
                state.isSending = false
                state.isSuccess = true
                state.lastTicketResult = result
                return .none

            case let .feedbackResponse(.failure(error)):
                state.isSending = false
                state.isSuccess = false
                state.error = error.localizedDescription
                return .none

            case .clearError:
                state.error = nil
                return .none

            case .copyTicketLink:
                if let url = state.lastTicketResult?.url {
                    UIPasteboard.general.string = url.absoluteString
                    state.showCopiedConfirmation = true
                    return .run { send in
                        try await Task.sleep(for: .seconds(2))
                        await send(.hideCopiedConfirmation)
                    }
                } else if let identifier = state.lastTicketResult?.identifier {
                    UIPasteboard.general.string = identifier
                    state.showCopiedConfirmation = true
                    return .run { send in
                        try await Task.sleep(for: .seconds(2))
                        await send(.hideCopiedConfirmation)
                    }
                }
                return .none

            case .toggleShareSheet:
                state.showShareSheet.toggle()
                return .none

            case .hideCopiedConfirmation:
                state.showCopiedConfirmation = false
                return .none

            case .improveDescription:
                guard !state.message.isEmpty else {
                    return .none
                }

                state.isImproving = true
                state.error = nil

                let currentDescription = state.message

                return .run { send in
                    let result = await Result {
                        try await descriptionEnhancer.enhance(currentDescription)
                    }
                    await send(.improveDescriptionResponse(result))
                }

            case let .improveDescriptionResponse(.success(improvedText)):
                state.isImproving = false
                state.message = improvedText
                state.isAIGenerated = true
                return .none

            case let .improveDescriptionResponse(.failure(error)):
                state.isImproving = false
                state.error = "Failed to improve description: \(error.localizedDescription)"
                return .none

            case .toggleMarkdownPreview:
                state.showMarkdownPreview.toggle()
                return .none

            case .captureScreenshot:
                return .run { send in
                    let image = screenshotCapture.capture()
                    await send(.screenshotCaptured(image))
                }

            case let .screenshotCaptured(image):
                state.screenshot = image
                return .none
            }
        }
    }
}
