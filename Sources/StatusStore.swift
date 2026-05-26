import Foundation

// provider を集約して /api/status の JSON をキャッシュする。
// 収集 (main 前提 API) は @MainActor refresh()、配信は lock 越しに任意スレッドから読む
// (Swifter ハンドラは別キューで走るため、MainActor を跨がず Data を返せるようにする)。
final class StatusStore {
    private let providers: [SegmentProvider]
    private let lock = NSLock()
    private var cached = Data(#"{"version":1,"ts":0,"groups":[]}"#.utf8)

    init(providers: [SegmentProvider]) {
        self.providers = providers
    }

    @MainActor func refresh() {
        var groups: [Group] = []
        for p in providers {
            if let g = p.group() { groups.append(g) }
        }
        let doc = StatusDoc(version: 1, ts: Int(Date().timeIntervalSince1970 * 1000), groups: groups)
        let encoded = (try? JSONEncoder().encode(doc)) ?? Data("{}".utf8)
        lock.lock()
        cached = encoded
        lock.unlock()
    }

    /// 任意スレッドから安全に読める (HTTP ハンドラ用)。
    func snapshotData() -> Data {
        lock.lock()
        defer { lock.unlock() }
        return cached
    }
}
