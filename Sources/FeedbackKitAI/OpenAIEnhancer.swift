import Foundation
import FeedbackKitCore

/// OpenAI implementation of DescriptionEnhancer
public struct OpenAIEnhancer: DescriptionEnhancer {
    private let configuration: AIConfiguration
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    public init(configuration: AIConfiguration) {
        self.configuration = configuration
    }

    public func enhance(_ description: String) async throws -> String {
        let payload: [String: Any] = [
            "model": configuration.model,
            "messages": [
                [
                    "role": "system",
                    "content": configuration.systemPrompt
                ],
                [
                    "role": "user",
                    "content": "Improve this bug report description: \(description)"
                ]
            ],
            "temperature": configuration.temperature,
            "max_tokens": configuration.maxTokens
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: payload)

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, resp) = try await URLSession.shared.data(for: request)

        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.requestFailed("OpenAI request failed: \(errorMessage)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse("Failed to parse OpenAI response")
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
