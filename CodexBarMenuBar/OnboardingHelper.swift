import AppKit
import Foundation

@MainActor
enum OnboardingHelper {
    private static let codexbarPaths = ["/opt/homebrew/bin/codexbar", "/usr/local/bin/codexbar"]
    private static let dismissedKey = "codexbarMissingAlertDismissed"

    static var isCodexBarInstalled: Bool {
        codexbarPaths.contains { FileManager.default.isExecutableFile(atPath: $0) }
    }

    static func checkAndPromptIfMissing() {
        guard !isCodexBarInstalled else { return }
        guard !UserDefaults.standard.bool(forKey: dismissedKey) else { return }

        let alert = NSAlert()
        alert.messageText = "CodexBar CLI Not Found"
        alert.informativeText = """
        CodexBarMenuBar requires CodexBar to fetch AI usage data. Without it, the menu bar will be empty.

        Install CodexBar via Homebrew? This will open Terminal and run the install command.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Install via Homebrew")
        alert.addButton(withTitle: "Visit Website")
        alert.addButton(withTitle: "Don't Show Again")

        NSApp.activate()
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            launchInstallScript()
        case .alertSecondButtonReturn:
            if let url = URL(string: "https://github.com/steipete/CodexBar") {
                NSWorkspace.shared.open(url)
            }
        case .alertThirdButtonReturn:
            UserDefaults.standard.set(true, forKey: dismissedKey)
        default:
            break
        }
    }

    /// Writes a `.command` file (executable shell script) and opens it.
    /// macOS opens .command files in Terminal automatically, running the script.
    /// No accessibility permission needed.
    private static func launchInstallScript() {
        let scriptURL = FileManager.default.temporaryDirectory.appendingPathComponent("install-codexbar.command")
        let script = """
        #!/bin/bash
        echo "Installing CodexBar via Homebrew..."
        echo ""
        brew install --cask codexbar
        echo ""
        echo "Done. You can close this Terminal window."
        """
        do {
            try script.write(to: scriptURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)
            NSWorkspace.shared.open(scriptURL)
        } catch {
            // Fallback: copy command to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString("brew install --cask codexbar", forType: .string)

            let fallback = NSAlert()
            fallback.messageText = "Command Copied"
            fallback.informativeText = "The install command has been copied to your clipboard. Open Terminal and paste it (⌘V) to run."
            fallback.runModal()
        }
    }
}
