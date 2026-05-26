import MediaPlayer

// POST /api/action {id} の処理。再生制御は systemMusicPlayer = Apple Music 限定。
// (Spotify 等 他社アプリの制御は公開 API では不可。詳細は README 参照。)
enum ActionHandler {
    @MainActor static func handle(_ id: String) -> Bool {
        let p = MPMusicPlayerController.systemMusicPlayer
        switch id {
        case "music.playpause":
            if p.playbackState == .playing { p.pause() } else { p.play() }
        case "music.next":
            p.skipToNextItem()
        case "music.prev":
            p.skipToPreviousItem()
        default:
            return false
        }
        return true
    }
}
