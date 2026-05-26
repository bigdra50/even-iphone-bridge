import Foundation
import Swifter

// ローカル HTTP サーバー。127.0.0.1:PORT で待受け、同一端末の EvenApp WebView から fetch される。
// GET /api/status  … キャッシュ済み StatusDoc
// GET /api/machine … toolbar の machine 識別用
// POST /api/action … {id} で再生制御等
final class LocalServer {
    private let server = HttpServer()
    private let store: StatusStore

    init(store: StatusStore) {
        self.store = store
    }

    func start(port: in_port_t = 8723) {
        let cors = ["Access-Control-Allow-Origin": "*"]

        server.GET["/api/status"] = { [store] _ in
            .raw(200, "OK", cors.merging(["Content-Type": "application/json"]) { _, b in b }) { w in
                try w.write([UInt8](store.snapshotData()))
            }
        }

        server.GET["/api/machine"] = { _ in
            let body = #"{"machineId":"iphone-local","label":"iPhone","availableSources":[]}"#
            return .raw(200, "OK", cors.merging(["Content-Type": "application/json"]) { _, b in b }) { w in
                try w.write([UInt8](body.utf8))
            }
        }

        server.POST["/api/action"] = { req in
            guard
                let obj = try? JSONSerialization.jsonObject(with: Data(req.body)) as? [String: Any],
                let id = obj["id"] as? String
            else {
                return .badRequest(.text("missing id"))
            }
            DispatchQueue.main.async { _ = ActionHandler.handle(id) }
            return .raw(200, "OK", cors, nil)
        }

        do {
            try server.start(port, forceIPv4: true)
        } catch {
            print("[LocalServer] start error: \(error)")
        }
    }
}
