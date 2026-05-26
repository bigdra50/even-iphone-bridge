import UIKit

// 端末バッテリー (UIDevice)。EvenApp の WebView では取れない iPhone 本体の電池。
struct BatteryProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        guard level >= 0 else { return nil } // -1 は不明 (シミュレータ等)
        let pct = Int((level * 100).rounded())
        let charging = [.charging, .full].contains(UIDevice.current.batteryState)
        return Group(
            id: "iphone",
            label: "iPhone",
            segments: [
                Segment(
                    id: "battery",
                    label: "Battery",
                    value: "\(pct)%\(charging ? "+" : "")",
                    percent: pct,
                    defaultEnabled: true
                )
            ]
        )
    }
}
