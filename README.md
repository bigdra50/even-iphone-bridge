# eveng2-iphone-bridge

iPhone 上でローカル HTTP サーバーを建て、`eveng2-toolbar` (Even G2) に
iPhone 側の情報 (バッテリー/音量/Apple Music) を `/api/status` で提供する PoC。

EvenApp の WebView では取れないネイティブ情報を、自前アプリに委譲して segment 化する。
toolbar 側は接続先 URL を `http://127.0.0.1:8723` にするだけで変更不要。

## 構成

```
App.swift          SwiftUI @main。起動時に server/store/keepAlive を開始
Models.swift       Segment/Group/StatusDoc (toolbar の status-types.ts と一致)
Providers/         SegmentProvider 実装
  BatteryProvider  UIDevice の端末バッテリー
  VolumeProvider   AVAudioSession.outputVolume (読み取りのみ)
  MusicProvider    Apple Music の now-playing (systemMusicPlayer)
StatusStore.swift  provider を集約し JSON をキャッシュ (lock 越しに任意スレッドへ)
ActionHandler.swift POST /api/action の再生制御 (Apple Music 限定)
LocalServer.swift  Swifter で /api/status, /api/machine, /api/action
KeepAlive.swift    無音ループ再生で background suspend を回避 (mixWithOthers)
```

## ビルド

```bash
xcodegen generate          # project.yml → EvenG2Bridge.xcodeproj
open EvenG2Bridge.xcodeproj
# Signing チームを設定し、実機 (iPhone) にビルド
```

初回起動で Apple Music (メディアライブラリ) 許可を求める。

## toolbar との接続

1. このアプリを iPhone で起動したままにする
2. EvenApp で toolbar を開き、Machine 設定の接続先に `http://127.0.0.1:8723` を入力
3. 接続テスト → iPhone の battery/volume/music が segment として出る

## API

| メソッド | パス | 内容 |
|---|---|---|
| GET | `/api/status` | StatusDoc (groups/segments) |
| GET | `/api/machine` | machineId/label |
| POST | `/api/action` | `{"id":"music.playpause"\|"music.next"\|"music.prev"}` |

curl 確認 (アプリ起動中の iPhone と同一端末、または LAN):

```bash
curl http://127.0.0.1:8723/api/status | jq
curl -X POST http://127.0.0.1:8723/api/action -d '{"id":"music.next"}'
```

## 音楽制御の制約 (重要)

- 再生制御・now-playing 取得は **Apple Music (標準ミュージック) 限定** (`MPMusicPlayerController.systemMusicPlayer`)。
- **Spotify / YouTube 等 他社アプリ、および「現在再生中のアプリを問わず制御」(イヤホンのタップ相当) は公開 API では不可。**
  - イヤホンタップは hardware → システム → 現在の now-playing アプリ、という OS レベルの仕組み。
  - アプリからその system-wide コマンドを送る公開 API は無い (private の MediaRemote のみで、App Store 不可かつ近年は entitlement gate でサイドロードでも不可)。
- 音量は **読み取りのみ**。設定の公開 API は無い (`MPVolumeView` のグレー手法のみ)。

## バックグラウンド

`Info.plist` の `UIBackgroundModes: [audio]` + KeepAlive の無音ループで、
EvenApp 前面 / 端末ロック中もサーバーを生かす。自分用 (private) 前提。
public 配布では「実際に audio を使う必然性」が審査で問われる。
