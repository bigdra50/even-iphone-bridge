import UIKit

struct BrightnessProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let pct = Int((UIScreen.main.brightness * 100).rounded())
        return Group(
            id: "brightness",
            label: "Brightness",
            segments: [Segment(id: "level", label: "Bright", value: "\(pct)%", percent: pct, defaultEnabled: true)]
        )
    }
}
