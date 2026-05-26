import Foundation
import Network

// NWPathMonitor は非同期コールバックなので、起動時から監視して最新値をキャッシュし、
// provider.group() (同期) はキャッシュを読む。
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let lock = NSLock()
    private var cached = "-"

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let s: String
            if path.status != .satisfied {
                s = "Offline"
            } else if path.usesInterfaceType(.wifi) {
                s = "WiFi"
            } else if path.usesInterfaceType(.cellular) {
                s = "Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                s = "Wired"
            } else {
                s = "On"
            }
            self?.lock.lock()
            self?.cached = s
            self?.lock.unlock()
        }
        monitor.start(queue: DispatchQueue(label: "net.monitor"))
    }

    var status: String {
        lock.lock()
        defer { lock.unlock() }
        return cached
    }
}

struct NetworkProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        Group(
            id: "network",
            label: "Network",
            segments: [Segment(id: "type", label: "Net", value: NetworkMonitor.shared.status, defaultEnabled: true)]
        )
    }
}
