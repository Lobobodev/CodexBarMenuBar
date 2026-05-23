import SwiftUI

@main
struct CodexBarMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openSettings) private var openSettings

    var body: some Scene {
        let _ = { AppDelegate.openSettingsAction = openSettings }()

        Settings {
            SettingsView(dataManager: appDelegate.dataManager)
        }
        .windowResizability(.contentSize)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static var openSettingsAction: OpenSettingsAction?

    private var menuBarManager: MenuBarManager?
    let dataManager = UsageDataManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarManager = MenuBarManager(dataManager: dataManager)
        QuotaNotifier.shared.requestPermissionIfNeeded()

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            OnboardingHelper.checkAndPromptIfMissing()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        dataManager.stop()
    }
}
