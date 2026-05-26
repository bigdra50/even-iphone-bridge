import MediaPlayer
import SwiftUI

@main
struct EvenG2BridgeApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}

@MainActor
final class AppModel: ObservableObject {
    let port: in_port_t = 8723
    @Published var lastUpdate: Date?

    private let store: StatusStore
    private let server: LocalServer
    private let keepAlive = KeepAlive()
    private var timer: Timer?
    private var started = false

    init() {
        store = StatusStore(providers: [
            BatteryProvider(),
            VolumeProvider(),
            MusicProvider(),
        ])
        server = LocalServer(store: store)
    }

    func start() {
        guard !started else { return }
        started = true
        MPMediaLibrary.requestAuthorization { _ in } // Apple Music の now-playing/制御用
        keepAlive.start()
        store.refresh()
        server.start(port: port)
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.store.refresh()
                self?.lastUpdate = Date()
            }
        }
        lastUpdate = Date()
    }
}

struct ContentView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        VStack(spacing: 16) {
            Text("EvenG2 Bridge")
                .font(.title2.bold())
            Text("toolbar の接続先に入力:")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("http://127.0.0.1:\(String(model.port))")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
            if let t = model.lastUpdate {
                Text("更新: \(t.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("このアプリを起動したまま EvenApp を開くと、iPhone のバッテリー/音量/Apple Music を\nグラスに表示できます。")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .onAppear { model.start() }
    }
}
