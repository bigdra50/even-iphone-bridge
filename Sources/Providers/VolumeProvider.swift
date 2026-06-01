import AVFoundation

// システム出力音量 (読み取りのみ)。設定は公開 API では不可 (MPVolumeView のグレー手法のみ)。
struct VolumeProvider: SegmentProvider {
    @MainActor func segments() -> [Segment] {
        let v = AVAudioSession.sharedInstance().outputVolume // 0...1
        let pct = Int((v * 100).rounded())
        return [Segment(id: "volume", label: "Vol", value: "\(pct)%", percent: pct, defaultEnabled: true)]
    }
}
