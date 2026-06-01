import Foundation

struct UptimeProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        let s = Int(ProcessInfo.processInfo.systemUptime)
        let h = s / 3600
        let m = (s % 3600) / 60
        let v = h > 0 ? "\(h)h\(m)m" : "\(m)m"
        return [Segment(id: "uptime", label: "Up", value: v, defaultEnabled: false)]
    }
}
