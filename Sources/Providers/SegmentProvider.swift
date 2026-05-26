import Foundation

// provider を足すだけで表示要素が増える (toolbar 側はサーバー側と同じモデル)。
// UIDevice / MediaPlayer / AVAudioSession 等は main 前提のため @MainActor。
protocol SegmentProvider {
    @MainActor func group() -> Group?
}
