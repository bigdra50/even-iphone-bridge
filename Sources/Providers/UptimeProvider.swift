import Foundation

struct UptimeProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let s = Int(ProcessInfo.processInfo.systemUptime)
        let h = s / 3600
        let m = (s % 3600) / 60
        let v = h > 0 ? "\(h)h\(m)m" : "\(m)m"
        return Group(
            id: "uptime",
            label: "Uptime",
            segments: [Segment(id: "up", label: "Up", value: v, defaultEnabled: false)]
        )
    }
}
