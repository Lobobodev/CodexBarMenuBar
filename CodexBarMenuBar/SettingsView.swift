import SwiftUI
import ServiceManagement
import UniformTypeIdentifiers

// MARK: - Settings Tab

enum SettingsTab: String, CaseIterable {
    case general, providers, about

    var label: String {
        switch self {
        case .general: return "General"
        case .providers: return "Providers"
        case .about: return "About"
        }
    }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .providers: return "square.grid.2x2"
        case .about: return "info.circle"
        }
    }

    static let defaultWidth: CGFloat = 546
    static let providersWidth: CGFloat = 792
    static let windowHeight: CGFloat = 638

    var preferredWidth: CGFloat {
        self == .providers ? Self.providersWidth : Self.defaultWidth
    }

    var preferredHeight: CGFloat {
        Self.windowHeight
    }
}

// MARK: - Reusable: SettingsSection

struct SettingsSection<Content: View>: View {
    let title: String?
    let caption: String?
    let contentSpacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(title: String? = nil, caption: String? = nil, spacing: CGFloat = 14, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.caption = caption
        self.contentSpacing = spacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            if let caption {
                Text(caption)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            VStack(alignment: .leading, spacing: contentSpacing) {
                content()
            }
        }
    }
}

// MARK: - Reusable: PreferenceToggleRow

struct PreferenceToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5.4) {
            Toggle(isOn: $isOn) {
                Text(title).font(.body)
            }
            .toggleStyle(.checkbox)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Reusable: ProviderSettingsSection

struct ProviderSettingsSection<Content: View>: View {
    let title: String
    let spacing: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    @ViewBuilder let content: () -> Content

    init(title: String, spacing: CGFloat = 12, verticalPadding: CGFloat = 10, horizontalPadding: CGFloat = 4, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.spacing = spacing
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(title).font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }
}

// MARK: - Main Settings View

struct SettingsView: View {
    @Bindable var dataManager: UsageDataManager
    @State private var selectedTab: SettingsTab = .general
    @State private var contentWidth: CGFloat = SettingsTab.defaultWidth
    @State private var contentHeight: CGFloat = SettingsTab.windowHeight

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView(dataManager: dataManager)
                .tabItem { Label(SettingsTab.general.label, systemImage: SettingsTab.general.icon) }
                .tag(SettingsTab.general)

            ProvidersSettingsView(dataManager: dataManager)
                .tabItem { Label(SettingsTab.providers.label, systemImage: SettingsTab.providers.icon) }
                .tag(SettingsTab.providers)

            AboutSettingsView()
                .tabItem { Label(SettingsTab.about.label, systemImage: SettingsTab.about.icon) }
                .tag(SettingsTab.about)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(width: contentWidth, height: contentHeight)
        .onAppear {
            updateLayout(for: selectedTab, animate: false)
        }
        .onChange(of: selectedTab) { _, newTab in
            updateLayout(for: newTab, animate: true)
        }
    }

    private func updateLayout(for tab: SettingsTab, animate: Bool) {
        let change = {
            self.contentWidth = tab.preferredWidth
            self.contentHeight = tab.preferredHeight
        }
        if animate {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) { change() }
        } else {
            change()
        }
        Self.resizeSettingsWindow(width: tab.preferredWidth, height: tab.preferredHeight, animate: animate)
    }

    private static let settingsWindowIdentifier = "com_apple_SwiftUI_Settings_window"
    private static let knownTabTitles = Set(SettingsTab.allCases.map(\.label))

    private static func resizeSettingsWindow(width: CGFloat, height: CGFloat, animate: Bool) {
        guard let window = NSApp.windows.first(where: {
            $0.identifier?.rawValue == settingsWindowIdentifier
                || knownTabTitles.contains($0.title)
        }) else { return }
        let toolbarHeight = window.frame.height - window.contentLayoutRect.height
        guard toolbarHeight > 0 else { return }
        let newSize = NSSize(width: width, height: height + toolbarHeight)
        var frame = window.frame
        frame.origin.y += frame.size.height - newSize.height
        frame.size = newSize
        window.setFrame(frame, display: true, animate: animate)
    }
}

// MARK: - General Tab

struct GeneralSettingsView: View {
    @Bindable var dataManager: UsageDataManager
    @AppStorage("refreshInterval") private var refreshInterval: Double = 300
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showUsageAsUsed") private var showUsageAsUsed = true
    @AppStorage("resetTimeAsAbsolute") private var resetTimeAsAbsolute = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSection(title: "System") {
                    PreferenceToggleRow(
                        "Start at Login",
                        subtitle: "Automatically launch CodexBarMenuBar when you log in.",
                        isOn: $launchAtLogin
                    )
                    .onChange(of: launchAtLogin) {
                        LaunchAtLoginHelper.setEnabled(launchAtLogin)
                    }
                }

                Divider()

                SettingsSection(title: "Automation") {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("Refresh cadence")
                                .font(.subheadline.weight(.semibold))

                            Picker("", selection: $refreshInterval) {
                                Text("Manual").tag(0.0)
                                Text("1 min").tag(60.0)
                                Text("2 min").tag(120.0)
                                Text("5 min").tag(300.0)
                                Text("15 min").tag(900.0)
                                Text("30 min").tag(1800.0)
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(maxWidth: 200)
                            .controlSize(.small)
                            .onChange(of: refreshInterval) {
                                dataManager.restartTimer()
                            }

                            Spacer(minLength: 0)
                        }

                        Text("How often CodexBarMenuBar polls providers in the background.")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)

                        if refreshInterval == 0 {
                            Text("Auto-refresh is off; use the menu's Refresh command.")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Divider()

                SettingsSection(title: "Display") {
                    PreferenceToggleRow(
                        "Show usage as used",
                        subtitle: "Progress bars fill as you consume quota (instead of showing remaining).",
                        isOn: $showUsageAsUsed
                    )

                    PreferenceToggleRow(
                        "Show reset time as clock",
                        subtitle: "Display reset times as absolute clock values instead of countdowns.",
                        isOn: $resetTimeAsAbsolute
                    )
                }

                Divider()

                HStack {
                    Spacer()
                    Button("Quit CodexBarMenuBar") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Providers Tab

struct ProvidersSettingsView: View {
    @Bindable var dataManager: UsageDataManager
    @State private var selectedID: String?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ProviderSidebarView(
                dataManager: dataManager,
                selectedID: $selectedID
            )

            if let id = selectedID ?? dataManager.orderedProviderConfigs.first?.id,
               let config = ProviderConfig.byID[id] {
                ProviderDetailView(config: config, dataManager: dataManager)
            } else {
                ContentUnavailableView(
                    "Select a Provider",
                    systemImage: "square.grid.2x2",
                    description: Text("Choose a provider from the list to configure.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear {
            if selectedID == nil {
                selectedID = dataManager.orderedProviderConfigs.first?.id
            }
        }
    }
}

// MARK: - Provider Sidebar

struct ProviderSidebarView: View {
    @Bindable var dataManager: UsageDataManager
    @Binding var selectedID: String?
    @State private var draggingProvider: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(dataManager.orderedProviderConfigs) { config in
                    ProviderSidebarRowView(
                        config: config,
                        isSelected: selectedID == config.id,
                        dataManager: dataManager
                    )
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(selectedID == config.id
                                  ? Color(nsColor: .selectedContentBackgroundColor)
                                  : Color.clear)
                            .padding(.horizontal, 4)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selectedID = config.id }
                    .onDrag {
                        draggingProvider = config.id
                        return NSItemProvider(object: config.id as NSString)
                    }
                    .onDrop(
                        of: [UTType.plainText],
                        delegate: ProviderDropDelegate(
                            item: config.id,
                            providerOrder: $dataManager.providerOrder,
                            dragging: $draggingProvider
                        )
                    )
                }
            }
            .padding(.vertical, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.7), lineWidth: 1)
        )
        .frame(minWidth: 240, maxWidth: 240)
    }
}

// MARK: - Provider Sidebar Row

struct ProviderSidebarRowView: View {
    let config: ProviderConfig
    let isSelected: Bool
    @Bindable var dataManager: UsageDataManager

    private var isEnabled: Bool {
        dataManager.enabledIDSet.contains(config.id)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ProviderSidebarReorderHandle()
                .padding(.vertical, 4)
                .padding(.horizontal, 2)

            if let icon = ProviderIcons.icon(for: config.id, size: 18) {
                Image(nsImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(isSelected ? .white : .primary)
            } else {
                Image(systemName: "app.fill")
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(config.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : .primary)

                    ProviderStatusDot(
                        usage: dataManager.usages[config.id],
                        isEnabled: isEnabled
                    )
                }

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { enabled in
                    if enabled {
                        if !dataManager.enabledProviderIDs.contains(config.id) {
                            dataManager.enabledProviderIDs.append(config.id)
                        }
                    } else {
                        dataManager.enabledProviderIDs.removeAll { $0 == config.id }
                    }
                }
            ))
            .labelsHidden()
            .toggleStyle(.checkbox)
            .controlSize(.small)
        }
        .padding(.vertical, 2)
    }

    private var statusText: String {
        guard isEnabled else { return "Disabled" }
        guard let usage = dataManager.usages[config.id] else { return "No data" }
        if let err = usage.error { return err }
        if let s = usage.sessionPercent {
            if let w = usage.weeklyPercent {
                return "\(Int(s))% · W:\(Int(w))%"
            }
            return "\(Int(s))%"
        }
        if let b = usage.balance { return b }
        return "OK"
    }
}

// MARK: - Sidebar Reorder Handle

struct ProviderSidebarReorderHandle: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 3) {
                    Circle().frame(width: 2, height: 2)
                    Circle().frame(width: 2, height: 2)
                }
            }
        }
        .frame(width: 12, height: 12)
        .foregroundStyle(.tertiary)
    }
}

// MARK: - Status Dot

struct ProviderStatusDot: View {
    let usage: ProviderUsage?
    let isEnabled: Bool

    var body: some View {
        Circle()
            .fill(dotColor)
            .frame(width: 6, height: 6)
    }

    private var dotColor: Color {
        guard isEnabled else { return .gray }
        guard let usage else { return .gray }
        if usage.error != nil { return .red }
        if let s = usage.sessionPercent {
            if s >= 95 { return .red }
            if s >= 80 { return .orange }
            if s >= 50 { return .yellow }
            return .green
        }
        if usage.balance != nil { return .green }
        return .gray
    }
}

// MARK: - Provider Drop Delegate

struct ProviderDropDelegate: DropDelegate {
    let item: String
    @Binding var providerOrder: [String]
    @Binding var dragging: String?

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != item else { return }
        guard let fromIndex = providerOrder.firstIndex(of: dragging),
              let toIndex = providerOrder.firstIndex(of: item)
        else { return }
        if fromIndex == toIndex { return }
        withAnimation(.default) {
            providerOrder.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }
}

// MARK: - Provider Detail

struct ProviderDetailView: View {
    let config: ProviderConfig
    @Bindable var dataManager: UsageDataManager

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { dataManager.enabledIDSet.contains(config.id) },
            set: { enabled in
                if enabled {
                    if !dataManager.enabledProviderIDs.contains(config.id) {
                        dataManager.enabledProviderIDs.append(config.id)
                    }
                } else {
                    dataManager.enabledProviderIDs.removeAll { $0 == config.id }
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                providerHeader

                providerInfoGrid

                if let usage = dataManager.usages[config.id], isEnabled.wrappedValue {
                    currentUsageSection(usage)
                }
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Header

    private var providerHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                if let icon = ProviderIcons.icon(for: config.id, size: 28) {
                    Image(nsImage: icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.primary)
                } else {
                    Image(systemName: "app.fill")
                        .font(.title2)
                        .frame(width: 28, height: 28)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(config.displayName)
                        .font(.title3.weight(.semibold))
                    Text("codexbar usage --provider \(config.cliName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                if dataManager.isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                }

                Button {
                    Task { await dataManager.refresh(providerID: config.id) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(dataManager.isRefreshing)

                Toggle("", isOn: isEnabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
        }
    }

    // MARK: Info Grid

    private var providerInfoGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
            GridRow {
                Text("State")
                    .frame(width: 80, alignment: .leading)
                Text(isEnabled.wrappedValue ? "Enabled" : "Disabled")
            }
            GridRow {
                Text("CLI Name")
                    .frame(width: 80, alignment: .leading)
                Text(config.cliName)
            }
            GridRow {
                Text("Type")
                    .frame(width: 80, alignment: .leading)
                Text(config.displayType == .usageBar ? "Subscription (Usage)" : "Balance (Credit)")
            }
            if let usage = dataManager.usages[config.id] {
                if let org = usage.accountOrganization {
                    GridRow {
                        Text("Account")
                            .frame(width: 80, alignment: .leading)
                        Text(org)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                if let source = usage.source {
                    GridRow {
                        Text("Source")
                            .frame(width: 80, alignment: .leading)
                        Text(source)
                    }
                }
                if let date = usage.lastUpdated {
                    GridRow {
                        Text("Updated")
                            .frame(width: 80, alignment: .leading)
                        Text("\(date, style: .relative) ago")
                    }
                }
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    // MARK: Current Usage

    @ViewBuilder
    private func currentUsageSection(_ usage: ProviderUsage) -> some View {
        ProviderSettingsSection(title: "Usage & Menu Bar Display", spacing: 10, verticalPadding: 6, horizontalPadding: 0) {
            if let s = usage.sessionPercent {
                usageMetricRow(windowKey: "session", label: "Session", percent: s, resetsAt: usage.sessionResetsAt)
            }
            if let w = usage.weeklyPercent {
                usageMetricRow(windowKey: "weekly", label: "Weekly", percent: w, resetsAt: usage.weeklyResetsAt)
            }
            ForEach(usage.extraWindows, id: \.id) { extra in
                usageMetricRow(windowKey: extra.id, label: extra.title, percent: extra.usedPercent, resetsAt: extra.resetsAt)
            }
            if let b = usage.balance {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Text("Balance")
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 60, alignment: .leading)
                        Text(b)
                            .font(.footnote)
                            .monospacedDigit()
                    }
                    HStack(spacing: 12) {
                        Toggle("Show Balance", isOn: showBalanceBinding)
                            .toggleStyle(.checkbox)
                            .font(.caption)
                            .controlSize(.small)
                    }
                    .padding(.leading, 70)
                }
                .padding(.vertical, 2)
            }
            if let err = usage.error {
                HStack(alignment: .top, spacing: 10) {
                    Text("Error")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 60, alignment: .leading)
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var showBalanceBinding: Binding<Bool> {
        Binding(
            get: { (dataManager.displaySettings[config.id] ?? ProviderDisplaySettings()).showBalance },
            set: { newValue in
                var s = dataManager.displaySettings[config.id] ?? ProviderDisplaySettings()
                s.showBalance = newValue
                dataManager.displaySettings[config.id] = s
            }
        )
    }

    @AppStorage("resetTimeAsAbsolute") private var resetTimeAsAbsolute = false

    private func usageMetricRow(windowKey: String, label: String, percent: Double, resetsAt: Date? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 60, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor(percent))
                                .frame(width: geo.size.width * min(CGFloat(percent) / 100, 1.0))
                        }
                    }
                    .frame(minWidth: 220, maxWidth: .infinity)
                    .frame(height: 8)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(Int(percent))% used")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Spacer(minLength: 8)
                        if let resetText = ResetTimeFormatter.resetLine(date: resetsAt, asAbsolute: resetTimeAsAbsolute) {
                            Text(resetText)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            windowDisplayToggles(for: windowKey, hasResetTime: resetsAt != nil)
        }
        .padding(.vertical, 4)
    }

    private func windowDisplayToggles(for key: String, hasResetTime: Bool) -> some View {
        HStack(spacing: 14) {
            Toggle("Bar", isOn: windowSettingBinding(key: key, keyPath: \.showBar))
                .toggleStyle(.checkbox)
            Toggle("%", isOn: windowSettingBinding(key: key, keyPath: \.showPercent))
                .toggleStyle(.checkbox)
            if hasResetTime {
                Toggle("⏱ Bar", isOn: windowSettingBinding(key: key, keyPath: \.showCountdownBar))
                    .toggleStyle(.checkbox)
                Toggle("⏱ Text", isOn: windowSettingBinding(key: key, keyPath: \.showCountdownText))
                    .toggleStyle(.checkbox)
            }
        }
        .font(.caption)
        .controlSize(.small)
        .padding(.leading, 70)
    }

    private func windowSettingBinding(key: String, keyPath: WritableKeyPath<WindowDisplaySettings, Bool>) -> Binding<Bool> {
        Binding(
            get: {
                let ds = dataManager.displaySettings[config.id] ?? ProviderDisplaySettings()
                return ds.settings(for: key)[keyPath: keyPath]
            },
            set: { newValue in
                var ds = dataManager.displaySettings[config.id] ?? ProviderDisplaySettings()
                var ws = ds.settings(for: key)
                ws[keyPath: keyPath] = newValue
                ds.setSettings(for: key, ws)
                dataManager.displaySettings[config.id] = ds
            }
        )
    }

    private func progressColor(_ percent: Double) -> Color {
        switch percent {
        case ..<50: return .green
        case 50..<80: return .yellow
        case 80..<95: return .orange
        default: return .red
        }
    }
}

// MARK: - About Tab

struct AboutSettingsView: View {
    @State private var iconHover = false

    var body: some View {
        VStack(spacing: 12) {
            Button {
                if let url = URL(string: "https://github.com/steipete/CodexBar") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .frame(width: 92, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .scaleEffect(iconHover ? 1.05 : 1.0)
                    .shadow(color: iconHover ? .accentColor.opacity(0.25) : .clear, radius: 6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                    iconHover = hovering
                }
            }

            VStack(spacing: 2) {
                Text("CodexBarMenuBar")
                    .font(.title3)
                    .bold()
                Text("Version 1.0")
                    .foregroundStyle(.secondary)
                Text("Keep your AI usage in view.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .center, spacing: 10) {
                AboutLinkRow(
                    icon: "terminal",
                    title: "Powered by CodexBar CLI",
                    url: "https://github.com/steipete/CodexBar"
                )
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            Divider()

            VStack(spacing: 4) {
                Text("Data source")
                    .font(.footnote.weight(.semibold))
                Text("/opt/homebrew/bin/codexbar")
                    .font(.footnote)
                    .monospaced()
                    .foregroundStyle(.secondary)
            }

            Text("\u{00A9} 2026 LoboAI. MIT License.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 4)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

// MARK: - About Link Row

struct AboutLinkRow: View {
    let icon: String
    let title: String
    let url: String
    @State private var hovering = false

    var body: some View {
        Button {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .underline(hovering, color: .accentColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }
}

// MARK: - Launch at Login

enum LaunchAtLoginHelper {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }
}
