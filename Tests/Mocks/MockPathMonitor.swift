import Network
@testable import SwiftReachability

final class MockPathMonitor: PathMonitorType {
    let path: PathType
    init(path: PathType = MockPath()) {
        self.path = path
    }

    let onPathUpdateCheck = FuncCheck<@Sendable (PathType) -> Void>()
    func onPathUpdate(_ callback: @escaping @Sendable (PathType) -> Void) {
        onPathUpdateCheck.call(callback)
    }

    let startCheck = FuncCheck<DispatchQueue>()
    func start(queue: DispatchQueue) {
        startCheck.call(queue)
    }

    let cancelCheck = FuncCheck<Void>()
    func cancel() {
        cancelCheck.call()
    }
}
