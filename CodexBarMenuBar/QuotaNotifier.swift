import AppKit
import UserNotifications

/// Posts macOS notifications when an AI provider's usage crosses a warning or
/// critical threshold. Tracks per-window/per-threshold state so a single bucket
/// crossing only fires once until usage drops below the threshold again or the
/// window resets.
@MainActor
final class QuotaNotifier {
    /// Threshold buckets, ordered from lowest to highest. The notifier only
    /// fires for the highest bucket whose threshold has been crossed.
    enum Severity: Int, CaseIterable {
        case warning, critical

        var emoji: String {
            switch self {
            case .warning: return "⚠️"
            case .critical: return "🚨"
            }
        }
    }

    static let shared = QuotaNotifier()

    private let center = UNUserNotificationCenter.current()
    private var fired: [String: Severity] = [:]  // key: "<providerID>:<windowKey>"
    private var permissionRequested = false

    private init() {}

    /// Call once on app launch (after MenuBarManager is set up).
    func requestPermissionIfNeeded() {
        guard !permissionRequested else { return }
        permissionRequested = true
        let alreadyAsked = UserDefaults.standard.bool(forKey: "notifPermissionRequested")
        guard !alreadyAsked else { return }
        UserDefaults.standard.set(true, forKey: "notifPermissionRequested")

        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Evaluate every enabled provider's session/weekly windows against the
    /// thresholds and post a notification for newly crossed buckets.
    func evaluate(providers: [ProviderConfig], usages: [String: ProviderUsage]) {
        guard UserDefaults.standard.bool(forKey: "quotaNotifEnabled") else { return }

        let warnThresh = UserDefaults.standard.object(forKey: "quotaNotifWarningThreshold") as? Double ?? 80
        let critThresh = UserDefaults.standard.object(forKey: "quotaNotifCriticalThreshold") as? Double ?? 95

        for config in providers {
            guard let usage = usages[config.id] else { continue }
            checkWindow(providerID: config.id,
                        providerName: config.displayName,
                        windowKey: "session",
                        windowLabel: String(localized: "Session"),
                        percent: usage.sessionPercent,
                        warn: warnThresh,
                        crit: critThresh)
            checkWindow(providerID: config.id,
                        providerName: config.displayName,
                        windowKey: "weekly",
                        windowLabel: String(localized: "Weekly"),
                        percent: usage.weeklyPercent,
                        warn: warnThresh,
                        crit: critThresh)
        }
    }

    private func checkWindow(providerID: String,
                             providerName: String,
                             windowKey: String,
                             windowLabel: String,
                             percent: Double?,
                             warn: Double,
                             crit: Double) {
        guard let p = percent else { return }
        let key = "\(providerID):\(windowKey)"
        let current: Severity?
        if p >= crit { current = .critical }
        else if p >= warn { current = .warning }
        else { current = nil }

        let previous = fired[key]

        // Reset record once usage drops back below the warning threshold so
        // the next time it climbs we can fire again.
        if current == nil {
            fired.removeValue(forKey: key)
            return
        }

        // Only post when severity escalates (warning → critical or fresh entry).
        guard current != previous,
              previous == nil || (previous == .warning && current == .critical) else {
            return
        }

        fired[key] = current
        post(providerName: providerName,
             windowLabel: windowLabel,
             percent: p,
             severity: current!)
    }

    private func post(providerName: String, windowLabel: String, percent: Double, severity: Severity) {
        let content = UNMutableNotificationContent()
        content.title = "\(severity.emoji) \(providerName) — \(windowLabel) \(Int(percent))%"
        content.body = severity == .critical
            ? String(localized: "You're about to hit your quota cap.")
            : String(localized: "Your usage is getting high.")
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "codexbarmenubar.quota.\(providerName).\(windowLabel).\(severity.rawValue)",
            content: content,
            trigger: nil
        )
        center.add(request) { _ in }
    }
}
