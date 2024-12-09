public enum ConnectionType: Hashable, CustomStringConvertible, Sendable {
    case cellular
    case wifi
    case wiredEthernet
    case loopback
    case unknown

    public var isCellular: Bool {
        guard case .cellular = self else { return false }
        return true
    }

    public var isWifi: Bool { self == .wifi }
    public var isWiredEthernet: Bool { self == .wiredEthernet }
    public var isLoopback: Bool { self == .loopback }
    public var isUnknown: Bool { self == .unknown }

    public var description: String {
        switch self {
        case .cellular: "Cellular"
        case .wifi: "Wi-Fi"
        case .wiredEthernet: "Ethernet"
        case .loopback: "Loopback"
        case .unknown: "Unknown"
        }
    }
}
