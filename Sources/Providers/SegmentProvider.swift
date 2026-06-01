import Foundation

// provider は segment を提供するだけ。複数 provider の segment を単一 "iphone" グループに
// まとめるのは StatusStore の責務 (iPhone bridge = 1 つの論理ソース = 1 グループ)。
// 値が取れない時は空配列を返す (その期間 segment を出さない)。
// UIDevice / MediaPlayer / AVAudioSession 等は main 前提のため @MainActor。
protocol SegmentProvider {
    @MainActor func segments() -> [Segment]
}
