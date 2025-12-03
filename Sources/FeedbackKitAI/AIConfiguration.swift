import Foundation

/// Configuration for AI-powered description enhancement
public struct AIConfiguration: Sendable {
    /// The AI provider to use
    public let provider: AIProvider

    /// API key for authentication
    public let apiKey: String

    /// Model identifier (e.g., "gpt-4o-mini", "claude-3-5-sonnet-20241022")
    public let model: String

    /// Maximum tokens in the response
    public let maxTokens: Int

    /// Temperature for response generation (0.0-1.0)
    public let temperature: Double

    /// System prompt to guide the AI
    public let systemPrompt: String

    public init(
        provider: AIProvider,
        apiKey: String,
        model: String,
        maxTokens: Int = 500,
        temperature: Double = 0.7,
        systemPrompt: String = """
        You are a helpful assistant that improves bug report descriptions. \
        Make them clear, concise, and professional while preserving all technical details. \
        Keep the improved description focused and under 500 characters unless more detail is necessary.
        """
    ) {
        self.provider = provider
        self.apiKey = apiKey
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.systemPrompt = systemPrompt
    }

    /// Default configuration for OpenAI
    public static func openAI(apiKey: String) -> AIConfiguration {
        AIConfiguration(
            provider: .openAI,
            apiKey: apiKey,
            model: "gpt-4o-mini"
        )
    }

    /// Default configuration for Anthropic Claude
    public static func anthropic(apiKey: String) -> AIConfiguration {
        AIConfiguration(
            provider: .anthropic,
            apiKey: apiKey,
            model: "claude-3-5-sonnet-20241022"
        )
    }

    /// Load configuration from environment variables
    ///
    /// Expected environment variables:
    /// - AI_PROVIDER ("openai" or "anthropic")
    /// - OPENAI_API_KEY (if using OpenAI)
    /// - ANTHROPIC_API_KEY (if using Anthropic)
    public static func fromEnvironment() throws -> AIConfiguration {
        guard let providerString = ProcessInfo.processInfo.environment["AI_PROVIDER"],
              let provider = AIProvider(rawValue: providerString) else {
            throw AIError.missingEnvironmentVariable("AI_PROVIDER")
        }

        let apiKey: String
        switch provider {
        case .openAI:
            guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
                throw AIError.missingEnvironmentVariable("OPENAI_API_KEY")
            }
            apiKey = key
        case .anthropic:
            guard let key = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] else {
                throw AIError.missingEnvironmentVariable("ANTHROPIC_API_KEY")
            }
            apiKey = key
        }

        return AIConfiguration(
            provider: provider,
            apiKey: apiKey,
            model: provider == .openAI ? "gpt-4o-mini" : "claude-3-5-sonnet-20241022"
        )
    }
}

/// Supported AI providers
public enum AIProvider: String, Sendable {
    case openAI = "openai"
    case anthropic = "anthropic"
}

/// Errors specific to AI operations
public enum AIError: Error, Equatable, LocalizedError {
    case missingEnvironmentVariable(String)
    case requestFailed(String)
    case invalidResponse(String)

    public var errorDescription: String? {
        switch self {
        case .missingEnvironmentVariable(let key):
            return "Missing required environment variable: \(key)"
        case .requestFailed(let message):
            return "AI request failed: \(message)"
        case .invalidResponse(let message):
            return "Invalid AI response: \(message)"
        }
    }
}
