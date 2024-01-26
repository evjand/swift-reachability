import Network
#if os(iOS)
import CoreTelephony
#endif

protocol PathMonitorType: Sendable {
    #if os(iOS)
    var telephonyNetworkInfo: TelephonyInfoType { get }
    #endif
    var path: PathType { get }

    func onPathUpdate(_ callback: @escaping (PathType) -> Void)
    func start(queue: DispatchQueue)
    func cancel()
}

extension PathMonitorType {
    func connectionStatus(for path: PathType) -> ConnectionStatus {
        switch path.status {
        case .satisfied: .connected(connectionType(for: path))
        case .unsatisfied, .requiresConnection: .disconnected(path.unsatisfiedReason.disconnectedReason)
        @unknown default: .disconnected(path.unsatisfiedReason.disconnectedReason)
        }
    }

    func connectionType(for path: PathType) -> ConnectionType {
        if path.usesInterfaceType(.loopback) { return .loopback }
        if path.usesInterfaceType(.wiredEthernet) { return .wiredEthernet }
        if path.usesInterfaceType(.wifi) { return .wifi }
        #if os(iOS)
        if path.usesInterfaceType(.cellular) { return .cellular(telephonyNetworkInfo.cellularConnectionType) }
        #endif

        return .unknown
    }
}

extension NWPathMonitor: PathMonitorType {
    #if os(iOS)
    var telephonyNetworkInfo: TelephonyInfoType { CTTelephonyNetworkInfo() }
    #endif
    var path: PathType { currentPath }

    func onPathUpdate(_ callback: @escaping (PathType) -> Void) {
        pathUpdateHandler = { callback($0) }
    }
}
