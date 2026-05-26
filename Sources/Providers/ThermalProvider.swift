import Foundation

struct ThermalProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let state: String
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: state = "nominal"
        case .fair: state = "fair"
        case .serious: state = "serious"
        case .critical: state = "critical"
        @unknown default: state = "?"
        }
        return Group(
            id: "thermal",
            label: "Thermal",
            segments: [Segment(id: "state", label: "Thermal", value: state, defaultEnabled: true)]
        )
    }
}
