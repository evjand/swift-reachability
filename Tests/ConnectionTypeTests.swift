import XCTest
@testable import SwiftReachability

final class ConnectionTypeTests: XCTestCase {
    func test_isWifi_shouldReturnCorrectValue() {
        XCTAssert(ConnectionType.wifi.isWifi)
        XCTAssertFalse(ConnectionType.cellular.isWifi)
        XCTAssertFalse(ConnectionType.wiredEthernet.isWifi)
        XCTAssertFalse(ConnectionType.loopback.isWifi)
        XCTAssertFalse(ConnectionType.unknown.isWifi)
    }

    func test_isWiredEthernet_shouldReturnCorrectValue() {
        XCTAssert(ConnectionType.wiredEthernet.isWiredEthernet)
        XCTAssertFalse(ConnectionType.wifi.isWiredEthernet)
        XCTAssertFalse(ConnectionType.loopback.isWiredEthernet)
        XCTAssertFalse(ConnectionType.unknown.isWiredEthernet)
        XCTAssertFalse(ConnectionType.cellular.isWiredEthernet)
    }

    func test_isLoopback_shouldReturnCorrectValue() {
        XCTAssert(ConnectionType.loopback.isLoopback)
        XCTAssertFalse(ConnectionType.wifi.isLoopback)
        XCTAssertFalse(ConnectionType.wiredEthernet.isLoopback)
        XCTAssertFalse(ConnectionType.unknown.isLoopback)
        XCTAssertFalse(ConnectionType.cellular.isLoopback)
    }

    func test_isUnknown_shouldReturnCorrectValue() {
        XCTAssert(ConnectionType.unknown.isUnknown)
        XCTAssertFalse(ConnectionType.wifi.isUnknown)
        XCTAssertFalse(ConnectionType.wiredEthernet.isUnknown)
        XCTAssertFalse(ConnectionType.loopback.isUnknown)
        XCTAssertFalse(ConnectionType.cellular.isUnknown)
    }
}
