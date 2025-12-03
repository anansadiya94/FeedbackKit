import Foundation

/// Configuration for Jira API integration
public struct JiraConfiguration: Sendable {
    /// Base URL of the Jira instance (e.g., "https://company.atlassian.net")
    public let baseURL: URL

    /// Jira user email for authentication
    public let email: String

    /// Jira API token for authentication
    public let apiToken: String

    /// Jira project key (e.g., "IOS", "PROJ")
    public let projectKey: String

    /// Issue type (default: "Bug")
    public let issueType: String

    /// Custom Jira fields to include with issues
    public let customFields: [String: JiraFieldValue]

    public init(
        baseURL: URL,
        email: String,
        apiToken: String,
        projectKey: String,
        issueType: String = "Bug",
        customFields: [String: JiraFieldValue] = [:]
    ) {
        self.baseURL = baseURL
        self.email = email
        self.apiToken = apiToken
        self.projectKey = projectKey
        self.issueType = issueType
        self.customFields = customFields
    }

    /// Load configuration from environment variables
    ///
    /// Expected environment variables:
    /// - JIRA_BASE_URL
    /// - JIRA_EMAIL
    /// - JIRA_API_TOKEN
    /// - JIRA_PROJECT_KEY
    /// - JIRA_ISSUE_TYPE (optional, defaults to "Bug")
    public static func fromEnvironment() throws -> JiraConfiguration {
        guard let baseURLString = ProcessInfo.processInfo.environment["JIRA_BASE_URL"],
              let baseURL = URL(string: baseURLString) else {
            throw JiraError.missingEnvironmentVariable("JIRA_BASE_URL")
        }

        guard let email = ProcessInfo.processInfo.environment["JIRA_EMAIL"] else {
            throw JiraError.missingEnvironmentVariable("JIRA_EMAIL")
        }

        guard let apiToken = ProcessInfo.processInfo.environment["JIRA_API_TOKEN"] else {
            throw JiraError.missingEnvironmentVariable("JIRA_API_TOKEN")
        }

        guard let projectKey = ProcessInfo.processInfo.environment["JIRA_PROJECT_KEY"] else {
            throw JiraError.missingEnvironmentVariable("JIRA_PROJECT_KEY")
        }

        let issueType = ProcessInfo.processInfo.environment["JIRA_ISSUE_TYPE"] ?? "Bug"

        return JiraConfiguration(
            baseURL: baseURL,
            email: email,
            apiToken: apiToken,
            projectKey: projectKey,
            issueType: issueType
        )
    }
}

/// Represents different types of values for Jira custom fields
public enum JiraFieldValue: Sendable {
    /// A string value
    case string(String)

    /// An array of strings
    case array([String])

    /// A nested object with key-value pairs
    case nested([String: String])
}

/// Errors specific to Jira operations
public enum JiraError: Error, Equatable, LocalizedError {
    case missingEnvironmentVariable(String)
    case requestFailed(String)
    case invalidResponse(String)

    public var errorDescription: String? {
        switch self {
        case .missingEnvironmentVariable(let key):
            return "Missing required environment variable: \(key)"
        case .requestFailed(let message):
            return "Jira request failed: \(message)"
        case .invalidResponse(let message):
            return "Invalid Jira response: \(message)"
        }
    }
}
