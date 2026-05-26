import MediaPlayer
import SwiftUI

@main
struct EvenG2BridgeApp: App {
    @StateObject private var runtime = Runtime()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(runtime)
        }
    }
}

@MainActor
final class Runtime: ObservableObject {
    let port: in_port_t = 8723
    let providers = ProviderRegistry.all()
    @Published var lastUpdate: Date?

    private let settings = ProviderSettings()
    private let store: StatusStore
    private let server: LocalServer
    private let keepAlive = KeepAlive()
    private var timer: Timer?
    private var started = false

    init() {
        store = StatusStore(registry: providers, settings: settings)
        server = LocalServer(store: store)
    }

    func isEnabled(_ id: String) -> Bool { settings.isEnabled(id) }

    func toggle(_ info: ProviderInfo, _ on: Bool) {
        settings.set(info.id, on)
        if on, info.id == "music" {
            MPMediaLibrary.requestAuthorization { _ in } // steps は次回 refresh の startUpdates で許可要求
        }
        objectWillChange.send()
        store.refresh()
        lastUpdate = Date()
    }

    func start() {
        guard !started else { return }
        started = true
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
    @EnvironmentObject var runtime: Runtime

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("toolbar の接続先に入力:")
                            .font(.footnote).foregroundStyle(.secondary)
                        Text("http://127.0.0.1:\(String(runtime.port))")
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                } footer: {
                    if let t = runtime.lastUpdate {
                        Text("更新: \(t.formatted(date: .omitted, time: .standard))")
                    }
                }

                Section {
                    ForEach(runtime.providers) { info in
                        Toggle(isOn: Binding(
                            get: { runtime.isEnabled(info.id) },
                            set: { runtime.toggle(info, $0) }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(info.label)
                                if let perm = info.permission {
                                    Text("要 \(perm) 許可")
                                        .font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("表示する項目")
                } footer: {
                    Text("ここで有効にした項目が /api/status に出ます。グラスへ実際に出す ON/OFF と並び順は toolbar 側で調整します。")
                }
            }
            .navigationTitle("EvenG2 Bridge")
        }
        .onAppear { runtime.start() }
    }
}
