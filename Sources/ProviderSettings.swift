import Foundation

// どの provider を有効化するかを UserDefaults に永続化する。
// 有効な provider だけが /api/status に出る (権限が要るものは opt-in)。
final class ProviderSettings {
    private let key = "enabledProviders"
    private var enabled: Set<String>

    // 初回の既定 ON (無権限のもの)。権限が要るもの (music/steps) は既定 OFF。
    private static let defaultEnabled: Set<String> = [
        "iphone", "power", "thermal", "storage", "network", "audio", "volume", "brightness",
    ]

    init() {
        if let arr = UserDefaults.standard.array(forKey: key) as? [String] {
            enabled = Set(arr)
        } else {
            enabled = Self.defaultEnabled
        }
    }

    func isEnabled(_ id: String) -> Bool { enabled.contains(id) }

    func set(_ id: String, _ on: Bool) {
        if on { enabled.insert(id) } else { enabled.remove(id) }
        UserDefaults.standard.set(Array(enabled), forKey: key)
    }
}
