import Foundation

struct StorageProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        guard
            let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
            let free = values.volumeAvailableCapacityForImportantUsage
        else { return [] }
        let gb = Double(free) / 1_000_000_000
        return [Segment(id: "storage", label: "Free", value: String(format: "%.1fGB", gb), defaultEnabled: true)]
    }
}
