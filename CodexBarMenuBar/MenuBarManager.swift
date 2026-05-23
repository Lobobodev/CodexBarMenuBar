import AppKit
import SwiftUI

@MainActor
final class MenuBarManager {
    private let statusItem: NSStatusItem
    private let dataManager: UsageDataManager
    private var observation: Task<Void, Never>?

    init(dataManager: UsageDataManager) {
        self.dataManager = dataManager
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        setupMenu()
        updateDisplay()
        startObserving()
        dataManager.start()
    }

    deinit {
        observation?.cancel()
    }

    private func setupMenu() {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: String(localized: "Settings..."), action: #selector(openSettings(_:)), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let refreshItem = NSMenuItem(title: String(localized: "Refresh"), action: #selector(refreshClicked(_:)), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: String(localized: "Quit CodexBarMenuBar"), action: #selector(quitClicked(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func startObserving() {
        observation = Task { [weak self] in
            while !Task.isCancelled {
                let hasCountdown = self?.hasActiveCountdown() ?? false
                let interval: Duration = hasCountdown ? .milliseconds(500) : .seconds(5)
                try? await Task.sleep(for: interval)
                self?.updateDisplay()
            }
        }
    }

    private func hasActiveCountdown() -> Bool {
        for config in dataManager.enabledConfigs {
            let ds = dataManager.displaySetting(for: config.id)
            guard let usage = dataManager.usages[config.id] else { continue }

            let windows: [(String, Date?)] = [
                ("session", usage.sessionResetsAt),
                ("weekly", usage.weeklyResetsAt)
            ] + usage.extraWindows.map { ($0.id, $0.resetsAt) }

            for (key, resetsAt) in windows {
                guard resetsAt != nil else { continue }
                let ws = ds.settings(for: key)
                if ws.showCountdownBar || ws.showCountdownText { return true }
            }
        }
        return false
    }

    private func updateDisplay() {
        let providers = dataManager.enabledConfigs.map { config -> StatusItemRenderer.ProviderData in
            let usage = dataManager.usages[config.id] ?? .empty
            let ds = dataManager.displaySetting(for: config.id)

            var rateWindows: [StatusItemRenderer.RateWindowData] = []
            if let s = usage.sessionPercent {
                rateWindows.append(.init(
                    key: "session", menuBarPrefix: nil,
                    usedPercent: s, resetsAt: usage.sessionResetsAt,
                    windowMinutes: usage.sessionWindowMinutes, settings: ds.settings(for: "session")
                ))
            }
            if let w = usage.weeklyPercent {
                rateWindows.append(.init(
                    key: "weekly", menuBarPrefix: " W:",
                    usedPercent: w, resetsAt: usage.weeklyResetsAt,
                    windowMinutes: usage.weeklyWindowMinutes, settings: ds.settings(for: "weekly")
                ))
            }
            for extra in usage.extraWindows {
                let prefix = " \(extra.title.prefix(1)):"
                rateWindows.append(.init(
                    key: extra.id, menuBarPrefix: prefix,
                    usedPercent: extra.usedPercent, resetsAt: extra.resetsAt,
                    windowMinutes: extra.windowMinutes, settings: ds.settings(for: extra.id)
                ))
            }

            return StatusItemRenderer.ProviderData(
                providerID: config.id,
                displayType: config.displayType,
                balance: usage.balance,
                showBalance: ds.showBalance,
                rateWindows: rateWindows
            )
        }

        if providers.isEmpty {
            statusItem.button?.image = nil
            statusItem.button?.title = "CodexBarMenuBar"
            statusItem.button?.toolTip = nil
        } else {
            statusItem.button?.title = ""
            statusItem.button?.image = StatusItemRenderer.renderCombined(providers: providers)
            statusItem.button?.toolTip = buildTooltip()
        }
    }

    private func buildTooltip() -> String {
        let asAbsolute = UserDefaults.standard.bool(forKey: "resetTimeAsAbsolute")
        var lines: [String] = []
        for config in dataManager.enabledConfigs {
            guard let usage = dataManager.usages[config.id] else { continue }
            var line = config.displayName + ": "
            if let s = usage.sessionPercent {
                line += "\(Int(s))%"
                if let w = usage.weeklyPercent { line += " · W:\(Int(w))%" }
                if let reset = ResetTimeFormatter.resetLine(date: usage.sessionResetsAt, asAbsolute: asAbsolute) {
                    line += " · \(reset)"
                }
            } else if let b = usage.balance {
                line += b
            } else if let err = usage.error {
                line += err
            } else {
                line += "--"
            }
            lines.append(line)

            for extra in usage.extraWindows {
                lines.append("  \(extra.title): \(Int(extra.usedPercent))%")
            }
        }
        return lines.joined(separator: "\n")
    }

    @objc private func openSettings(_ sender: Any?) {
        NSApp.activate()
        AppDelegate.openSettingsAction?()
    }

    @objc private func refreshClicked(_ sender: Any?) {
        Task { await dataManager.refresh() }
    }

    @objc private func quitClicked(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
}
