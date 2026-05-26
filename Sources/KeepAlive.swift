import AVFoundation

// バックグラウンド (EvenApp 前面 / 端末ロック中) でアプリが suspend されないよう、
// 無音を mixWithOthers でループ再生して audio background mode を維持する。
// mixWithOthers なのでユーザーの音楽再生は止めない。
final class KeepAlive {
    private var player: AVAudioPlayer?

    func start() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("silence.wav")
            if !FileManager.default.fileExists(atPath: url.path) {
                try SilentWav.data(seconds: 1).write(to: url)
            }
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = 0
            p.play()
            player = p
        } catch {
            print("[KeepAlive] error: \(error)")
        }
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
