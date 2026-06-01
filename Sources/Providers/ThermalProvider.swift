import Foundation

struct ThermalProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        let state: String
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: state = "nominal"
        case .fair: state = "fair"
        case .serious: state = "serious"
        case .critical: state = "critical"
        @unknown default: state = "?"
        }
        return [Segment(id: "thermal", label: "Thermal", value: state, defaultEnabled: true)]
    }
}
