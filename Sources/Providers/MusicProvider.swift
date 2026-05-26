import MediaPlayer

// Apple Music (標準ミュージック) の now-playing。systemMusicPlayer は公開 API。
// Spotify 等 他社アプリの曲情報は公開 API では取得不可。
// グラスの 4-bit フォント向けに記号は ASCII (> / ||) に留める。
struct MusicProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let player = MPMusicPlayerController.systemMusicPlayer
        guard let item = player.nowPlayingItem else {
            return Group(
                id: "music",
                label: "Music",
                segments: [Segment(id: "now", label: "Now", value: "-", defaultEnabled: true)]
            )
        }
        let title = item.title ?? "Unknown"
        let artist = item.artist ?? ""
        let np = artist.isEmpty ? title : "\(title) - \(artist)"
        let state = player.playbackState == .playing ? ">" : "||"
        return Group(
            id: "music",
            label: "Music",
            segments: [Segment(id: "now", label: "Now", value: "\(state) \(np)", defaultEnabled: true)]
        )
    }
}
