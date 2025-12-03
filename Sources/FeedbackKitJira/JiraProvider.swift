import Foundation
import FeedbackKitCore
#if canImport(UIKit)
import UIKit
#endif

/// Jira implementation of FeedbackProvider
public struct JiraProvider: FeedbackProvider {
    private let configuration: JiraConfiguration

    public init(configuration: JiraConfiguration) {
        self.configuration = configuration
    }

    public func submit(
        _ feedback: FeedbackItem,
        metadata: FeedbackMetadata
    ) async throws -> FeedbackResult {
        // Create the issue first
        let issueKey = try await createIssue(
            summary: feedback.title,
            description: formatDescription(feedback, metadata)
        )

        // Upload attachments if any
        for attachment in feedback.attachments {
            try await uploadAttachment(issueKey: issueKey, attachment: attachment)
        }

        // Return result with issue key and URL
        return FeedbackResult(
            identifier: issueKey,
            url: URL(string: "\(configuration.baseURL)/browse/\(issueKey)"),
            providerName: "Jira"
        )
    }

    // MARK: - Private Helpers

    private var authHeader: String {
        let combined = "\(configuration.email):\(configuration.apiToken)"
        let data = combined.data(using: .utf8) ?? Data()
        return "Basic \(data.base64EncodedString())"
    }

    private func formatDescription(_ feedback: FeedbackItem, _ metadata: FeedbackMetadata) -> String {
        var description = feedback.description.isEmpty ? "No description provided" : feedback.description

        // Append metadata
        description += """


        ---
        **Environment Information**
        Device: \(metadata.deviceModel)
        OS Version: \(metadata.osVersion)
        App Version: \(metadata.appVersion) (Build \(metadata.appBuild))
        Locale: \(metadata.locale)
        """

        // Append custom fields if any
        if !metadata.customFields.isEmpty {
            description += "\n"
            for (key, value) in metadata.customFields.sorted(by: { $0.key < $1.key }) {
                description += "\n\(key): \(value)"
            }
        }

        if feedback.isAIGenerated {
            description += "\n\n_Description enhanced by AI_"
        }

        return description
    }

    private func createIssue(summary: String, description: String) async throws -> String {
        let url = configuration.baseURL.appendingPathComponent("/rest/api/3/issue")

        // Build the payload with custom fields
        var fields: [String: Any] = [
            "project": ["key": configuration.projectKey],
            "summary": summary,
            "issuetype": ["name": configuration.issueType],
            "description": [
                "type": "doc",
                "version": 1,
                "content": [
                    [
                        "type": "paragraph",
                        "content": [
                            ["type": "text", "text": description]
                        ]
                    ]
                ]
            ]
        ]

        // Add custom fields
        for (key, value) in configuration.customFields {
            switch value {
            case .string(let str):
                fields[key] = str
            case .array(let arr):
                fields[key] = arr.map { ["value": $0] }
            case .nested(let dict):
                fields[key] = dict
            }
        }

        let payload: [String: Any] = ["fields": fields]
        let jsonData = try JSONSerialization.data(withJSONObject: payload)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, resp) = try await URLSession.shared.data(for: request)

        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw JiraError.requestFailed("Create issue failed: \(errorMessage)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let issueKey = json?["key"] as? String else {
            throw JiraError.invalidResponse("Missing 'key' in Jira response")
        }

        return issueKey
    }

    private func uploadAttachment(issueKey: String, attachment: FeedbackAttachment) async throws {
        let url = configuration.baseURL.appendingPathComponent("/rest/api/3/issue/\(issueKey)/attachments")

        let boundary = "Boundary-\(UUID().uuidString)"

        // Extract data from attachment
        let (fileData, filename, mimeType): (Data, String, String) = {
            switch attachment.type {
            #if canImport(UIKit)
            case .image(let image, let quality):
                let data = image.jpegData(compressionQuality: quality) ?? Data()
                return (data, "screenshot-\(UUID().uuidString).jpg", "image/jpeg")
            #endif
            case .data(let data, let mime, let name):
                return (data, name, mime)
            }
        }()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("no-check", forHTTPHeaderField: "X-Atlassian-Token")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Start boundary
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (_, resp) = try await URLSession.shared.data(for: request)

        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw JiraError.requestFailed("Attachment upload failed for \(issueKey)")
        }
    }
}
