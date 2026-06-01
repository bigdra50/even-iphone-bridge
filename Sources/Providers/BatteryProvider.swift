import UIKit

// 端末バッテリー (UIDevice)。EvenApp の WebView では取れない iPhone 本体の電池。
struct BatteryProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        guard level >= 0 else { return [] } // -1 は不明 (シミュレータ等)
        let pct = Int((level * 100).rounded())
        let charging = [.charging, .full].contains(UIDevice.current.batteryState)
        return [
            Segment(
                id: "battery",
                label: "Battery",
                value: "\(pct)%\(charging ? "+" : "")",
                percent: pct,
                defaultEnabled: true
            )
        ]
    }
}
