import Foundation
import os

@MainActor
@Observable
final class UsageDataManager {
    var usages: [String: ProviderUsage] = [:]
    var enabledProviderIDs: [String] = [] {
        didSet { UserDefaults.standard.set(enabledProviderIDs, forKey: "enabledProviderIDs") }
    }
    var displaySettings: [String: ProviderDisplaySettings] = [:] {
        didSet { saveDisplaySettings() }
    }
    var providerOrder: [String] = [] {
        didSet { UserDefaults.standard.set(providerOrder, forKey: "providerOrder") }
    }

    var isRefreshing = false

    private let logger = Logger(subsystem: "com.loboai.CodexBarMenuBar", category: "UsageData")
    private let codexbarPath: String = {
        let candidates = ["/opt/homebrew/bin/codexbar", "/usr/local/bin/codexbar"]
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
            ?? "/opt/homebrew/bin/codexbar"
    }()
    private var timerTask: Task<Void, Never>?
    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    var enabledIDSet: Set<String> { Set(enabledProviderIDs) }

    var enabledConfigs: [ProviderConfig] {
        let enabled = enabledIDSet
        return providerOrder.compactMap { id in
            guard enabled.contains(id) else { return nil }
            return ProviderConfig.byID[id]
        }
    }

    var orderedProviderConfigs: [ProviderConfig] {
        providerOrder.compactMap { id in
            ProviderConfig.byID[id]
        }
    }

    init() {
        if let saved = UserDefaults.standard.array(forKey: "enabledProviderIDs") as? [String], !saved.isEmpty {
            enabledProviderIDs = saved
        } else {
            enabledProviderIDs = Array(ProviderConfig.defaultEnabledIDs).sorted()
        }

        let allIDs = ProviderConfig.allProviders.map(\.id)
        if let savedOrder = UserDefaults.standard.array(forKey: "providerOrder") as? [String], !savedOrder.isEmpty {
            let allIDSet = Set(allIDs)
            var order = savedOrder.filter { allIDSet.contains($0) }
            let missing = allIDs.filter { !order.contains($0) }
            order.append(contentsOf: missing)
            providerOrder = order
        } else {
            providerOrder = allIDs
        }

        loadDisplaySettings()
    }

    func displaySetting(for id: String) -> ProviderDisplaySettings {
        displaySettings[id] ?? ProviderDisplaySettings()
    }

    private func saveDisplaySettings() {
        if let data = try? JSONEncoder().encode(displaySettings) {
            UserDefaults.standard.set(data, forKey: "providerDisplaySettings")
        }
    }

    private func loadDisplaySettings() {
        if let data = UserDefaults.standard.data(forKey: "providerDisplaySettings"),
           let decoded = try? JSONDecoder().decode([String: ProviderDisplaySettings].self, from: data) {
            displaySettings = decoded
        }
    }

    func restartTimer() {
        stop()
        start()
    }

    func start() {
        Task { await refresh() }
        let interval = UserDefaults.standard.double(forKey: "refreshInterval")
        guard interval > 0 else { return }
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                await self?.refresh()
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        let configs = enabledConfigs
        var results: [(String, Result<[CodexBarResponse], Error>)] = []
        await withTaskGroup(of: (String, Result<[CodexBarResponse], Error>).self) { group in
            for config in configs {
                group.addTask {
                    let result = await self.fetchProvider(config.cliName)
                    return (config.id, result)
                }
            }
            for await item in group {
                results.append(item)
            }
        }
        for (id, result) in results {
            if let config = ProviderConfig.byID[id] {
                usages[id] = parseUsage(result, config: config)
            }
        }
    }

    func refresh(providerID: String) async {
        guard let config = ProviderConfig.byID[providerID] else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let result = await fetchProvider(config.cliName)
        usages[providerID] = parseUsage(result, config: config)
    }

    private func fetchProvider(_ cliName: String) async -> Result<[CodexBarResponse], Error> {
        do {
            let data = try await runCLI(provider: cliName)
            let responses = try JSONDecoder().decode([CodexBarResponse].self, from: data)
            return .success(responses)
        } catch {
            logger.error("Failed to fetch \(cliName): \(error.localizedDescription)")
            return .failure(error)
        }
    }

    private func runCLI(provider: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: codexbarPath)
            process.arguments = ["usage", "--provider", provider, "--format", "json"]
            let stdout = Pipe()
            let stderr = Pipe()
            process.standardOutput = stdout
            process.standardError = stderr

            process.terminationHandler = { _ in
                let data = stdout.fileHandleForReading.readDataToEndOfFile()
                if process.terminationStatus != 0 {
                    let errMsg = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "exit \(process.terminationStatus)"
                    continuation.resume(throwing: CLIError.failed(errMsg))
                } else {
                    continuation.resume(returning: data)
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func parseUsage(_ result: Result<[CodexBarResponse], Error>, config: ProviderConfig) -> ProviderUsage {
        let existing = usages[config.id] ?? .empty
        switch result {
        case .success(let responses):
            guard let r = responses.first else { return ProviderUsage(error: "empty") }

            if let cliError = r.error, r.usage == nil {
                return ProviderUsage(
                    sessionPercent: existing.sessionPercent,
                    sessionWindowMinutes: existing.sessionWindowMinutes,
                    weeklyPercent: existing.weeklyPercent,
                    weeklyWindowMinutes: existing.weeklyWindowMinutes,
                    balance: existing.balance,
                    lastUpdated: existing.lastUpdated,
                    error: cliError.message,
                    sessionResetsAt: existing.sessionResetsAt,
                    weeklyResetsAt: existing.weeklyResetsAt,
                    extraWindows: existing.extraWindows
                )
            }

            guard let usage = r.usage else { return ProviderUsage(error: "no data") }

            func window(for field: ProviderConfig.RateWindowField) -> RateWindow? {
                switch field {
                case .primary: return usage.primary
                case .secondary: return usage.secondary
                case .tertiary: return usage.tertiary
                }
            }

            let extras = (usage.extraRateWindows ?? []).map { named in
                ExtraWindowUsage(
                    id: named.id,
                    title: named.title,
                    usedPercent: named.window.usedPercent,
                    resetsAt: named.window.resetsAt.flatMap { Self.iso8601.date(from: $0) },
                    windowMinutes: named.window.windowMinutes
                )
            }

            if config.displayType == .balance {
                let desc = window(for: config.balanceField ?? .primary)?.resetDescription
                let balance = desc.map { extractBalance(from: $0) }
                return ProviderUsage(balance: balance, lastUpdated: Date(), extraWindows: extras)
            } else {
                let sessionWin = window(for: config.sessionField)
                let weeklyWin = config.weeklyField.flatMap { window(for: $0) }
                return ProviderUsage(
                    sessionPercent: sessionWin?.usedPercent,
                    sessionWindowMinutes: sessionWin?.windowMinutes,
                    weeklyPercent: weeklyWin?.usedPercent,
                    weeklyWindowMinutes: weeklyWin?.windowMinutes,
                    lastUpdated: Date(),
                    sessionResetsAt: sessionWin?.resetsAt.flatMap { Self.iso8601.date(from: $0) },
                    weeklyResetsAt: weeklyWin?.resetsAt.flatMap { Self.iso8601.date(from: $0) },
                    extraWindows: extras
                )
            }

        case .failure(let error):
            return ProviderUsage(
                sessionPercent: existing.sessionPercent,
                sessionWindowMinutes: existing.sessionWindowMinutes,
                weeklyPercent: existing.weeklyPercent,
                weeklyWindowMinutes: existing.weeklyWindowMinutes,
                balance: existing.balance,
                lastUpdated: existing.lastUpdated,
                error: error.localizedDescription,
                sessionResetsAt: existing.sessionResetsAt,
                weeklyResetsAt: existing.weeklyResetsAt,
                extraWindows: existing.extraWindows
            )
        }
    }

    private func extractBalance(from description: String) -> String {
        if let range = description.range(of: #"[¥$€£]\d+\.?\d*"#, options: .regularExpression) {
            return String(description[range])
        }
        if let range = description.range(of: #"\d+\.?\d*\s*(credits?|pts?|points?)"#, options: [.regularExpression, .caseInsensitive]) {
            return String(description[range])
        }
        return description
    }
}

enum CLIError: Error, LocalizedError {
    case failed(String)
    var errorDescription: String? {
        switch self {
        case .failed(let msg): return msg
        }
    }
}
