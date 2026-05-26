import Foundation

// 利用可能な provider の一覧 (設定 UI と StatusStore が参照)。新規はここに足すだけ。
// id は生成する Group.id と一致させる (toolbar の config キーと揃う)。
struct ProviderInfo: Identifiable {
    let id: String
    let label: String // 設定 UI の表示名
    let permission: String? // nil = 不要、説明 = 要許可
    let provider: SegmentProvider
}

enum ProviderRegistry {
    static func all() -> [ProviderInfo] {
        [
            ProviderInfo(id: "iphone", label: "iPhone バッテリー", permission: nil, provider: BatteryProvider()),
            ProviderInfo(id: "power", label: "低電力モード", permission: nil, provider: LowPowerProvider()),
            ProviderInfo(id: "thermal", label: "発熱状態", permission: nil, provider: ThermalProvider()),
            ProviderInfo(id: "storage", label: "空きストレージ", permission: nil, provider: StorageProvider()),
            ProviderInfo(id: "network", label: "ネットワーク種別", permission: nil, provider: NetworkProvider()),
            ProviderInfo(id: "audio", label: "音声出力先", permission: nil, provider: AudioRouteProvider()),
            ProviderInfo(id: "volume", label: "音量", permission: nil, provider: VolumeProvider()),
            ProviderInfo(id: "brightness", label: "画面の明るさ", permission: nil, provider: BrightnessProvider()),
            ProviderInfo(id: "uptime", label: "稼働時間", permission: nil, provider: UptimeProvider()),
            ProviderInfo(id: "steps", label: "歩数", permission: "モーションと運動", provider: StepsProvider()),
            ProviderInfo(id: "music", label: "Apple Music", permission: "メディアライブラリ", provider: MusicProvider()),
        ]
    }
}
