import Foundation
import FeedbackKitCore

/// Anthropic Claude implementation of DescriptionEnhancer
public struct AnthropicEnhancer: DescriptionEnhancer {
    private let configuration: AIConfiguration
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!

    public init(configuration: AIConfiguration) {
        self.configuration = configuration
    }

    public func enhance(_ description: String) async throws -> String {
        let payload: [String: Any] = [
            "model": configuration.model,
            "max_tokens": configuration.maxTokens,
            "temperature": configuration.temperature,
            "system": configuration.systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": "Improve this bug report description: \(description)"
                ]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: payload)

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue(configuration.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, resp) = try await URLSession.shared.data(for: request)

        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.requestFailed("Anthropic request failed: \(errorMessage)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse("Failed to parse Anthropic response")
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
