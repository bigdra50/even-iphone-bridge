import CoreMotion
import Foundation

// CMPedometer は非同期更新なので、startUpdates で最新歩数をキャッシュし、group() はそれを返す。
// startUpdates の初回呼び出しでモーション許可ダイアログが出る。
final class StepsProvider: SegmentProvider {
    private let pedometer = CMPedometer()
    private let lock = NSLock()
    private var steps: Int?
    private var started = false

    private func startIfNeeded() {
        guard !started, CMPedometer.isStepCountingAvailable() else { return }
        started = true
        pedometer.startUpdates(from: Calendar.current.startOfDay(for: Date())) { [weak self] data, _ in
            guard let n = data?.numberOfSteps else { return }
            self?.lock.lock()
            self?.steps = n.intValue
            self?.lock.unlock()
        }
    }

    @MainActor func group() -> Group? {
        startIfNeeded()
        lock.lock()
        let s = steps
        lock.unlock()
        return Group(
            id: "steps",
            label: "Steps",
            segments: [Segment(id: "today", label: "Steps", value: s.map(String.init) ?? "-", defaultEnabled: true)]
        )
    }
}
