import UIKit

struct BrightnessProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        let pct = Int((UIScreen.main.brightness * 100).rounded())
        return [Segment(id: "brightness", label: "Bright", value: "\(pct)%", percent: pct, defaultEnabled: true)]
    }
}
