import Foundation

struct StorageProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        guard
            let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
            let free = values.volumeAvailableCapacityForImportantUsage
        else { return nil }
        let gb = Double(free) / 1_000_000_000
        return Group(
            id: "storage",
            label: "Storage",
            segments: [Segment(id: "free", label: "Free", value: String(format: "%.1fGB", gb), defaultEnabled: true)]
        )
    }
}
