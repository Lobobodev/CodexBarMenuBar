import AppKit

enum StatusItemRenderer {

    struct RateWindowData {
        let key: String
        let menuBarPrefix: String?
        let usedPercent: Double
        let resetsAt: Date?
        let windowMinutes: Int?
        let settings: WindowDisplaySettings
    }

    struct ProviderData {
        let providerID: String
        let displayType: DisplayType
        let balance: String?
        let showBalance: Bool
        let rateWindows: [RateWindowData]
    }

    static func renderCombined(providers: [ProviderData]) -> NSImage {
        let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ]

        let showAsUsed = UserDefaults.standard.object(forKey: "showUsageAsUsed") as? Bool ?? true
        let resetTimeAbsolute = UserDefaults.standard.bool(forKey: "resetTimeAsAbsolute")

        let totalHeight: CGFloat = 22
        let barWidth: CGFloat = 40
        let barHeight: CGFloat = 10
        let barY = (totalHeight - barHeight) / 2
        let countdownBarWidth: CGFloat = 28
        let countdownBarHeight: CGFloat = 6
        let iconSize: CGFloat = 16
        let dividerPad: CGFloat = 6

        var segments: [Segment] = []
        segments.append(.init(.spacer, 4))

        for (index, provider) in providers.enumerated() {
            if index > 0 {
                segments.append(.init(.spacer, dividerPad))
                segments.append(.init(.divider, 1))
                segments.append(.init(.spacer, dividerPad))
            }

            segments.append(.init(.icon(provider.providerID), iconSize))
            segments.append(.init(.spacer, 3))

            switch provider.displayType {
            case .usageBar:
                for rw in provider.rateWindows {
                    let ws = rw.settings
                    let hasAny = ws.showBar || ws.showPercent || ws.showCountdownBar || ws.showCountdownText
                    guard hasAny else { continue }

                    if ws.showBar {
                        segments.append(.init(.bar(rw.usedPercent), barWidth))
                        segments.append(.init(.spacer, 2))
                    }
                    if ws.showPercent {
                        let prefix = rw.menuBarPrefix ?? ""
                        let pctText = rw.usedPercent >= 0 ? "\(prefix)\(Int(rw.usedPercent))%" : "\(prefix)--"
                        segments.append(.init(.text(pctText), (pctText as NSString).size(withAttributes: attrs).width))
                    }
                    if let resetsAt = rw.resetsAt {
                        if ws.showCountdownBar {
                            let winMin = Double(rw.windowMinutes ?? 300)
                            let remainSec = max(0, resetsAt.timeIntervalSinceNow)
                            let remainPct = min(100, remainSec / (winMin * 60) * 100)
                            segments.append(.init(.spacer, 3))
                            segments.append(.init(.countdownBar(remainPct), countdownBarWidth))
                        }
                        if ws.showCountdownText {
                            let rText = " \(ResetTimeFormatter.format(date: resetsAt, asAbsolute: resetTimeAbsolute))"
                            segments.append(.init(.text(rText), (rText as NSString).size(withAttributes: attrs).width))
                        }
                    }
                    segments.append(.init(.spacer, 3))
                }

            case .balance:
                if provider.showBalance {
                    let text = provider.balance ?? "--"
                    segments.append(.init(.text(text), (text as NSString).size(withAttributes: attrs).width))
                }
            }
        }

        segments.append(.init(.spacer, 4))

        let totalWidth = segments.reduce(CGFloat(0)) { $0 + $1.width }

        let image = NSImage(size: NSSize(width: totalWidth, height: totalHeight), flipped: false) { _ in
            var x: CGFloat = 0
            for seg in segments {
                switch seg.kind {
                case .text(let str):
                    let size = (str as NSString).size(withAttributes: attrs)
                    let textY = (totalHeight - size.height) / 2
                    (str as NSString).draw(at: NSPoint(x: x, y: textY), withAttributes: attrs)

                case .icon(let providerID):
                    if let icon = ProviderIcons.icon(for: providerID, size: iconSize) {
                        let iconY = (totalHeight - iconSize) / 2
                        let iconRect = NSRect(x: x, y: iconY, width: iconSize, height: iconSize)
                        icon.draw(in: iconRect)
                        NSColor.labelColor.setFill()
                        iconRect.fill(using: .sourceAtop)
                    }

                case .bar(let percent):
                    let barRect = NSRect(x: x, y: barY, width: barWidth, height: barHeight)
                    NSColor.systemGray.withAlphaComponent(0.3).setFill()
                    NSBezierPath(roundedRect: barRect, xRadius: 3, yRadius: 3).fill()

                    if percent >= 0 {
                        let fillPct = showAsUsed ? percent : (100 - percent)
                        let fillW = barWidth * min(CGFloat(fillPct) / 100.0, 1.0)
                        if fillW > 0 {
                            let fillRect = NSRect(x: x, y: barY, width: fillW, height: barHeight)
                            colorForPercent(percent).setFill()
                            NSBezierPath(roundedRect: fillRect, xRadius: 3, yRadius: 3).fill()
                        }
                    }

                case .countdownBar(let remainingPct):
                    let cbY = (totalHeight - countdownBarHeight) / 2
                    let bgRect = NSRect(x: x, y: cbY, width: countdownBarWidth, height: countdownBarHeight)
                    NSColor.systemGray.withAlphaComponent(0.3).setFill()
                    NSBezierPath(roundedRect: bgRect, xRadius: 2, yRadius: 2).fill()

                    let fillW = countdownBarWidth * min(CGFloat(remainingPct) / 100.0, 1.0)
                    if fillW > 0 {
                        let fillRect = NSRect(x: x, y: cbY, width: fillW, height: countdownBarHeight)
                        colorForCountdown(remainingPct).setFill()
                        NSBezierPath(roundedRect: fillRect, xRadius: 2, yRadius: 2).fill()
                    }

                case .divider:
                    NSColor.separatorColor.setFill()
                    NSRect(x: x, y: 4, width: 1, height: totalHeight - 8).fill()

                case .spacer:
                    break
                }
                x += seg.width
            }
            return true
        }

        image.isTemplate = false
        return image
    }

    static func colorForPercent(_ percent: Double) -> NSColor {
        switch percent {
        case ..<50:
            return interpolate(from: .systemGreen, to: .systemYellow, t: percent / 50.0)
        case 50..<80:
            return interpolate(from: .systemYellow, to: .systemOrange, t: (percent - 50) / 30.0)
        case 80..<95:
            return interpolate(from: .systemOrange, to: .systemRed, t: (percent - 80) / 15.0)
        default:
            return .systemRed
        }
    }

    static func colorForCountdown(_ remainingPct: Double) -> NSColor {
        let inverted = 100 - remainingPct
        switch inverted {
        case ..<50:
            return interpolate(from: .systemRed, to: .systemYellow, t: inverted / 50.0)
        case 50..<80:
            return interpolate(from: .systemYellow, to: .systemGreen, t: (inverted - 50) / 30.0)
        default:
            return .systemGreen
        }
    }

    private static func interpolate(from: NSColor, to: NSColor, t: Double) -> NSColor {
        let f = from.usingColorSpace(.sRGB) ?? from
        let c = to.usingColorSpace(.sRGB) ?? to
        let t = max(0, min(1, t))
        return NSColor(
            red: f.redComponent + (c.redComponent - f.redComponent) * t,
            green: f.greenComponent + (c.greenComponent - f.greenComponent) * t,
            blue: f.blueComponent + (c.blueComponent - f.blueComponent) * t,
            alpha: 1.0
        )
    }

    private enum SegmentKind {
        case text(String)
        case icon(String)
        case bar(Double)
        case countdownBar(Double)
        case divider
        case spacer
    }

    private struct Segment {
        let kind: SegmentKind
        let width: CGFloat
        init(_ kind: SegmentKind, _ width: CGFloat) {
            self.kind = kind
            self.width = width
        }
    }
}
