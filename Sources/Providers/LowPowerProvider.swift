import Foundation

struct LowPowerProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let on = ProcessInfo.processInfo.isLowPowerModeEnabled
        return Group(
            id: "power",
            label: "Power",
            segments: [Segment(id: "lowpower", label: "Low Power", value: on ? "ON" : "off", defaultEnabled: true)]
        )
    }
}
