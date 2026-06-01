import Foundation

struct LowPowerProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        let on = ProcessInfo.processInfo.isLowPowerModeEnabled
        return [Segment(id: "lowpower", label: "Low Power", value: on ? "ON" : "off", defaultEnabled: true)]
    }
}
