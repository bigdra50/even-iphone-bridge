import Foundation

// 自端末の LAN IPv4 を返す。toolbar の接続先 URL を案内する用途。
// Wi-Fi (en0) を最優先し、無ければ最初の非ループバック IPv4 にフォールバックする。
// 取れない (Wi-Fi off 等) ときは nil。呼び出し側で 127.0.0.1 に落とす。
enum NetworkInfo {
    static func lanIPv4() -> String? {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return nil }
        defer { freeifaddrs(head) }

        var fallback: String?
        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            guard flags & IFF_UP == IFF_UP, flags & IFF_LOOPBACK == 0 else { continue }
            guard let addr = ptr.pointee.ifa_addr,
                  addr.pointee.sa_family == sa_family_t(AF_INET) else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                              &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0
            else { continue }

            let ip = String(cString: host)
            if String(cString: ptr.pointee.ifa_name) == "en0" { return ip } // Wi-Fi 確定
            if fallback == nil { fallback = ip }
        }
        return fallback
    }
}
