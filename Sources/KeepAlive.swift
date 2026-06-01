import AVFoundation

// バックグラウンド (EvenApp 前面 / 端末ロック中) でアプリが suspend されないよう、
// 無音を mixWithOthers でループ再生して audio background mode を維持する。
// mixWithOthers なのでユーザーの音楽 (YouTube/Spotify 等) は止めず共存する。
// 通話 / Siri / アラーム (interruption) や BT 切断・イヤホン抜き (route change) で
// 再生が止まっても自動で復帰し、サーバー稼働を保つ。
final class KeepAlive {
    private var player: AVAudioPlayer?
    private var observers: [NSObjectProtocol] = []

    func start() {
        prepare()
        activate()
        observe()
    }

    // 無音ループ player を用意する (まだ無ければ生成)。
    private func prepare() {
        guard player == nil else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("silence.wav")
        do {
            if !FileManager.default.fileExists(atPath: url.path) {
                try SilentWav.data(seconds: 1).write(to: url)
            }
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = 0
            p.prepareToPlay()
            player = p
        } catch {
            print("[KeepAlive] prepare error: \(error)")
        }
    }

    // セッションを有効化して無音ループを (再)開始する。初回起動と割り込み復帰の両方で使う。
    private func activate() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            player?.play()
        } catch {
            print("[KeepAlive] activate error: \(error)")
        }
    }

    // 割り込み終了・経路変更からの自動復帰を購読する。
    private func observe() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] note in
            // 通話/Siri/アラーム終了時に再開 (.shouldResume 有無に関わらず keep-alive 目的で復帰)。
            guard note.interruptionType == .ended else { return }
            self?.activate()
        })
        observers.append(center.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
        ) { [weak self] note in
            // BT 切断・イヤホン抜き (oldDeviceUnavailable) では OS が再生を止めるので鳴らし直す。
            guard note.routeChangeReason == .oldDeviceUnavailable else { return }
            self?.activate()
        })
    }

    deinit {
        for observer in observers { NotificationCenter.default.removeObserver(observer) }
    }
}

private extension Notification {
    var interruptionType: AVAudioSession.InterruptionType? {
        (userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt).flatMap(AVAudioSession.InterruptionType.init)
    }

    var routeChangeReason: AVAudioSession.RouteChangeReason? {
        (userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt).flatMap(AVAudioSession.RouteChangeReason.init)
    }
}

// 無音 16-bit PCM mono WAV を生成する (バンドルに音声ファイルを置かずに済ませる)。
enum SilentWav {
    static func data(seconds: Int, sampleRate: Int = 8000) -> Data {
        let samples = sampleRate * seconds
        let dataSize = samples * 2 // 16-bit mono
        var d = Data()
        func le32(_ v: Int) -> Data { var x = UInt32(v).littleEndian; return Data(bytes: &x, count: 4) }
        func le16(_ v: Int) -> Data { var x = UInt16(v).littleEndian; return Data(bytes: &x, count: 2) }
        d.append(Data("RIFF".utf8))
        d.append(le32(36 + dataSize))
        d.append(Data("WAVE".utf8))
        d.append(Data("fmt ".utf8))
        d.append(le32(16)) // PCM fmt chunk size
        d.append(le16(1)) // PCM
        d.append(le16(1)) // mono
        d.append(le32(sampleRate))
        d.append(le32(sampleRate * 2)) // byte rate
        d.append(le16(2)) // block align
        d.append(le16(16)) // bits per sample
        d.append(Data("data".utf8))
        d.append(le32(dataSize))
        d.append(Data(count: dataSize)) // 全て 0 = 無音
        return d
    }
}
