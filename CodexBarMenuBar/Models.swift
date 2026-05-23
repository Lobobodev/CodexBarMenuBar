import Foundation

// MARK: - Provider Configuration

enum DisplayType: String, Codable {
    case usageBar
    case balance
}

struct ProviderConfig: Identifiable, Codable {
    let id: String
    let displayName: String
    let cliName: String
    let displayType: DisplayType
    let sessionField: RateWindowField
    let weeklyField: RateWindowField?
    let balanceField: RateWindowField?

    enum RateWindowField: String, Codable {
        case primary, secondary, tertiary
    }
}

extension ProviderConfig {
    static let allProviders: [ProviderConfig] = [
        // Subscription with usage windows
        ProviderConfig(id: "claude", displayName: "Claude", cliName: "claude", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "codex", displayName: "Codex", cliName: "codex", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "zai", displayName: "ZAI", cliName: "zai", displayType: .usageBar,
                       sessionField: .tertiary, weeklyField: .primary, balanceField: nil),
        ProviderConfig(id: "cursor", displayName: "Cursor", cliName: "cursor", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "gemini", displayName: "Gemini", cliName: "gemini", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "copilot", displayName: "Copilot", cliName: "copilot", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "windsurf", displayName: "Windsurf", cliName: "windsurf", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "opencode", displayName: "OpenCode", cliName: "opencode", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "opencodego", displayName: "OC Go", cliName: "opencodego", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "alibaba", displayName: "Alibaba", cliName: "alibaba-coding-plan", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "antigravity", displayName: "Antigrav", cliName: "antigravity", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "kiro", displayName: "Kiro", cliName: "kiro", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "minimax", displayName: "MiniMax", cliName: "minimax", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "kimi", displayName: "Kimi", cliName: "kimi", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "factory", displayName: "Droid", cliName: "factory", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "augment", displayName: "Augment", cliName: "augment", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "jetbrains", displayName: "JB AI", cliName: "jetbrains", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "vertexai", displayName: "Vertex", cliName: "vertexai", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "mistral", displayName: "Mistral", cliName: "mistral", displayType: .usageBar,
                       sessionField: .primary, weeklyField: nil, balanceField: nil),
        ProviderConfig(id: "synthetic", displayName: "Synthetic", cliName: "synthetic", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "codebuff", displayName: "Codebuff", cliName: "codebuff", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "abacusai", displayName: "Abacus", cliName: "abacusai", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "perplexity", displayName: "Perplx", cliName: "perplexity", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "amp", displayName: "Amp", cliName: "amp", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),

        // Balance / credit based
        ProviderConfig(id: "deepseek", displayName: "DeepSeek", cliName: "deepseek", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "openrouter", displayName: "ORouter", cliName: "openrouter", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "warp", displayName: "Warp", cliName: "warp", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "kilo", displayName: "Kilo", cliName: "kilo", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "kimik2", displayName: "KimiK2", cliName: "kimik2", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),

        // Local (no billing)
        ProviderConfig(id: "ollama", displayName: "Ollama", cliName: "ollama", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),

        // New in CodexBar CLI v0.26+
        ProviderConfig(id: "openai", displayName: "OpenAI", cliName: "openai", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "manus", displayName: "Manus", cliName: "manus", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "moonshot", displayName: "Moonshot", cliName: "moonshot", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "mimo", displayName: "MiMo", cliName: "mimo", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "doubao", displayName: "Doubao", cliName: "doubao", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "crof", displayName: "Crof", cliName: "crof", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "venice", displayName: "Venice", cliName: "venice", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "commandcode", displayName: "CmdCode", cliName: "commandcode", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "stepfun", displayName: "StepFun", cliName: "stepfun", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "bedrock", displayName: "Bedrock", cliName: "bedrock", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),

        // New in CodexBar CLI v0.27+
        ProviderConfig(id: "elevenlabs", displayName: "11Labs", cliName: "elevenlabs", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "grok", displayName: "Grok", cliName: "grok", displayType: .balance,
                       sessionField: .primary, weeklyField: nil, balanceField: .primary),
        ProviderConfig(id: "groqcloud", displayName: "Groq", cliName: "groqcloud", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "llmproxy", displayName: "LLMProxy", cliName: "llmproxy", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "deepgram", displayName: "Deepgram", cliName: "deepgram", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),

        // New in CodexBar CLI v0.28+
        ProviderConfig(id: "azureopenai", displayName: "Azure", cliName: "azure-openai", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
        ProviderConfig(id: "t3chat", displayName: "T3 Chat", cliName: "t3chat", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),

        // New in CodexBar CLI v0.29+
        ProviderConfig(id: "alibabatokenplan", displayName: "Bailian", cliName: "alibaba-token-plan", displayType: .usageBar,
                       sessionField: .primary, weeklyField: .secondary, balanceField: nil),
    ]

    static let defaultEnabledIDs: Set<String> = ["claude", "zai", "deepseek"]

    static let byID: [String: ProviderConfig] = {
        Dictionary(uniqueKeysWithValues: allProviders.map { ($0.id, $0) })
    }()
}

// MARK: - CodexBar CLI JSON Response

struct CodexBarResponse: Decodable {
    let provider: String
    let usage: UsageData?
    let error: CodexBarError?
    let version: String?
    let source: String?
}

struct CodexBarError: Decodable {
    let message: String
    let code: Int?
    let kind: String?
}

struct UsageData: Decodable {
    let primary: RateWindow?
    let secondary: RateWindow?
    let tertiary: RateWindow?
    let accountEmail: String?
    let accountOrganization: String?
    let loginMethod: String?
    let updatedAt: String?
    let extraRateWindows: [NamedRateWindow]?
    let identity: AccountIdentity?
}

struct AccountIdentity: Decodable {
    let providerID: String?
    let accountEmail: String?
    let accountOrganization: String?
    let loginMethod: String?
}

struct RateWindow: Decodable {
    let usedPercent: Double
    let windowMinutes: Int?
    let resetsAt: String?
    let resetDescription: String?
}

struct NamedRateWindow: Decodable {
    let id: String
    let title: String
    let window: RateWindow
}

// MARK: - Per-Window Display Settings

struct WindowDisplaySettings: Codable, Equatable {
    var showBar: Bool
    var showPercent: Bool
    var showCountdownBar: Bool
    var showCountdownText: Bool

    static func defaults(for key: String) -> WindowDisplaySettings {
        switch key {
        case "session":
            return WindowDisplaySettings(showBar: true, showPercent: true, showCountdownBar: false, showCountdownText: false)
        case "weekly":
            return WindowDisplaySettings(showBar: false, showPercent: true, showCountdownBar: false, showCountdownText: false)
        default:
            return WindowDisplaySettings(showBar: false, showPercent: false, showCountdownBar: false, showCountdownText: false)
        }
    }
}

struct ProviderDisplaySettings: Codable {
    var windowSettings: [String: WindowDisplaySettings] = [:]
    var showBalance: Bool = true

    func settings(for key: String) -> WindowDisplaySettings {
        windowSettings[key] ?? WindowDisplaySettings.defaults(for: key)
    }

    mutating func setSettings(for key: String, _ value: WindowDisplaySettings) {
        windowSettings[key] = value
    }
}

// MARK: - Runtime Usage Data

struct ExtraWindowUsage {
    let id: String
    let title: String
    let usedPercent: Double
    let resetsAt: Date?
    let windowMinutes: Int?
}

struct ProviderUsage {
    var sessionPercent: Double?
    var sessionWindowMinutes: Int?
    var weeklyPercent: Double?
    var weeklyWindowMinutes: Int?
    var balance: String?
    var lastUpdated: Date?
    var error: String?
    var sessionResetsAt: Date?
    var weeklyResetsAt: Date?
    var extraWindows: [ExtraWindowUsage] = []
    var accountOrganization: String?
    var source: String?

    static let empty = ProviderUsage()
}

// MARK: - Reset Time Formatting

enum ResetTimeFormatter {
    static func format(date: Date, asAbsolute: Bool, now: Date = Date()) -> String {
        asAbsolute ? absoluteDescription(from: date, now: now) : countdownDescription(from: date, now: now)
    }

    static func resetLine(date: Date?, asAbsolute: Bool, now: Date = Date()) -> String? {
        guard let date else { return nil }
        return "Resets \(format(date: date, asAbsolute: asAbsolute, now: now))"
    }

    static func countdownDescription(from date: Date, now: Date = Date()) -> String {
        let seconds = max(0, date.timeIntervalSince(now))
        if seconds < 1 { return "now" }
        let totalMinutes = max(1, Int(ceil(seconds / 60.0)))
        let days = totalMinutes / (24 * 60)
        let hours = (totalMinutes / 60) % 24
        let minutes = totalMinutes % 60
        if days > 0 {
            return hours > 0 ? "in \(days)d \(hours)h" : "in \(days)d"
        }
        if hours > 0 {
            return minutes > 0 ? "in \(hours)h \(minutes)m" : "in \(hours)h"
        }
        return "in \(totalMinutes)m"
    }

    static func absoluteDescription(from date: Date, now: Date = Date()) -> String {
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: now) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "tomorrow, \(date.formatted(date: .omitted, time: .shortened))"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
