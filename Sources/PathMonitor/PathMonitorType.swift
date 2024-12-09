import Network

protocol PathMonitorType: Sendable {
    var path: PathType { get }

    func onPathUpdate(_ callback: @escaping @Sendable (PathType) -> Void)
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
        if path.usesInterfaceType(.cellular) { return .cellular }

        return .unknown
    }
}

#if hasAttribute(retroactive)
extension NWPathMonitor: @unchecked @retroactive Sendable {}
#else
extension NWPathMonitor: Sendable {}
#endif

extension NWPathMonitor: PathMonitorType {
    var path: PathType { currentPath }

    func onPathUpdate(_ callback: @escaping (PathType) -> Void) {
        pathUpdateHandler = { callback($0) }
    }
}
