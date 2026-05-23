import Foundation
import IOKit.ps

enum PowerSource {
    /// Returns `true` when the Mac is running on battery (not plugged in).
    static var isOnBattery: Bool {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef]
        else { return false }

        for source in sources {
            if let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any],
               let state = desc[kIOPSPowerSourceStateKey] as? String,
               state == kIOPSBatteryPowerValue {
                return true
            }
        }
        return false
    }
}
