import AVFoundation

// システム出力音量 (読み取りのみ)。設定は公開 API では不可 (MPVolumeView のグレー手法のみ)。
struct VolumeProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let v = AVAudioSession.sharedInstance().outputVolume // 0...1
        let pct = Int((v * 100).rounded())
        return Group(
            id: "volume",
            label: "Volume",
            segments: [
                Segment(id: "level", label: "Vol", value: "\(pct)%", percent: pct, defaultEnabled: true)
            ]
        )
    }
}
