import Foundation

// toolbar の src/status-types.ts と一致させるワイヤ型。キーは camelCase。
// /api/status が StatusDoc を返し、toolbar (glass/companion) が汎用描画する。

struct Segment: Codable {
    let id: String
    let label: String
    /// 表示文字列。整形済み (例 "62%" / "> Title - Artist" / "n/a")。
    let value: String
    /// progress bar 用 0-100。省略時は bar を描かない。
    var percent: Int?
    /// 副次表示 (任意)。
    var reset: String?
    /// 初回設定時の既定 ON/OFF。未指定は true 扱い。
    var defaultEnabled: Bool?

    init(
        id: String,
        label: String,
        value: String,
        percent: Int? = nil,
        reset: String? = nil,
        defaultEnabled: Bool? = nil
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.percent = percent
        self.reset = reset
        self.defaultEnabled = defaultEnabled
    }
}

struct Group: Codable {
    let id: String
    let label: String
    let segments: [Segment]
}

struct StatusDoc: Codable {
    let version: Int
    let ts: Int
    let groups: [Group]
}
