import Network
import XCTest
@testable import SwiftReachability

final class PathMonitorTests: XCTestCase {
    func test_connectionStatus_whenPathIsNotSatisfied_shouldReturnDisconnected() {
        let path = MockPath(status: .unsatisfied, unsatisfiedReason: .cellularDenied)
        let monitor = MockPathMonitor(path: path)
        let connectionStatus = monitor.connectionStatus(for: path)
        XCTAssertEqual(connectionStatus, .disconnected(.cellularDenied))
    }

    func test_connectionStatus_whenPathIsSatisfied_whenThereIsWiredInterface_shouldReturnCorrectConnection() {
        let monitor = MockPathMonitor(path: MockPath())
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wiredEthernet)
        let connectionStatus = monitor.connectionStatus(for: path)
        XCTAssertEqual(connectionStatus, .connected(.wiredEthernet))
    }

    func test_connectionStatus_whenPathIsSatisfied_whenThereIsLoopbackInterface_shouldReturnCorrectConnection() {
        let monitor = MockPathMonitor(path: MockPath())
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .loopback)
        let connectionStatus = monitor.connectionStatus(for: path)
        XCTAssertEqual(connectionStatus, .connected(.loopback))
    }

    func test_connectionStatus_whenPathIsSatisfied_whenThereIsWiFiInterface_shouldReturnCorrectConnection() {
        let monitor = MockPathMonitor(path: MockPath())
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
        let connectionStatus = monitor.connectionStatus(for: path)
        XCTAssertEqual(connectionStatus, .connected(.wifi))
    }

    func test_connectionStatus_whenPathIsSatisfied_whenThereIsCellularInterface_shouldReturnCorrectConnection() throws {
        let monitor = MockPathMonitor(path: MockPath())
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .cellular)
        let connectionStatus = monitor.connectionStatus(for: path)
        XCTAssertEqual(connectionStatus, .connected(.cellular))
    }

    func test_connectionStatus_whenPathIsSatisfied_whenThereIsUnsupportedInterface_shouldReturnCorrectConnection() {
        let monitor = MockPathMonitor(path: MockPath())
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .other)
        let connectionStatus = monitor.connectionStatus(for: path)
        XCTAssertEqual(connectionStatus, .connected(.unknown))
    }
}
