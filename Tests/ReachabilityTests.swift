import XCTest
import Combine
@testable import SwiftReachability

// swiftlint:disable:next type_body_length
final class ReachabilityTests: XCTestCase {
    private var bag = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        bag.removeAll()
    }

    @MainActor
    func test_isExpensive_shouldReturnCorrectValue() {
        let path = MockPath(status: .satisfied, isExpensive: true)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let isExpensive = networkReachability.isExpensive
        XCTAssert(isExpensive)
    }

    @MainActor
    func test_isConstrained_shouldReturnCorrectValue() {
        let path = MockPath(status: .satisfied, isConstrained: true)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let isConstrained = networkReachability.isConstrained
        XCTAssert(isConstrained)
    }

    @MainActor
    func test_status_shouldReturnConnectionStatus() {
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let connectionStatus = networkReachability.status
        XCTAssertEqual(connectionStatus, .connected(.wifi))
    }

    @MainActor
    func test_changes_whenConnectionStatusChanges_shouldNotify() async {
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "connection status changed")
        Task.detached {
            for await status in await networkReachability.changes() {
                XCTAssertEqual(status, .connected(.wiredEthernet))
                expectation.fulfill()
            }
        }
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newPath = MockPath(status: .satisfied, availableInterfaceTypes: .wiredEthernet)
            monitor.onPathUpdateCheck.argument?(newPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_changesPublisher_whenConnectionStatusChanges_shouldNotify() async {
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "connection status changed")
        networkReachability.changesPublisher().sink { status in
            XCTAssertEqual(status, .connected(.wiredEthernet))
            expectation.fulfill()
        }.store(in: &bag)
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newPath = MockPath(status: .satisfied, availableInterfaceTypes: .wiredEthernet)
            monitor.onPathUpdateCheck.argument?(newPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_changes_whenConnectionStatusDidNotChange_shouldNotNotify() async {
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "connection status changed")
        Task.detached {
            for await status in await networkReachability.changes() {
                XCTAssertEqual(status, .connected(.wiredEthernet))
                expectation.fulfill()
            }
        }
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newUnchangedPath = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
            monitor.onPathUpdateCheck.argument?(newUnchangedPath)
            let newChangedPath = MockPath(status: .satisfied, availableInterfaceTypes: .wiredEthernet)
            monitor.onPathUpdateCheck.argument?(newChangedPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_changesPublisher_whenConnectionStatusDidNotChange_shouldNotNotify() async {
        let path = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "connection status changed")
        networkReachability.changesPublisher().sink { status in
            XCTAssertEqual(status, .connected(.wiredEthernet))
            expectation.fulfill()
        }.store(in: &bag)
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newUnchangedPath = MockPath(status: .satisfied, availableInterfaceTypes: .wifi)
            monitor.onPathUpdateCheck.argument?(newUnchangedPath)
            let newChangedPath = MockPath(status: .satisfied, availableInterfaceTypes: .wiredEthernet)
            monitor.onPathUpdateCheck.argument?(newChangedPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_expensiveChanges_whenCostChanges_shouldNotify() async {
        let path = MockPath(status: .satisfied, isExpensive: true)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "cost changed")
        Task.detached {
            for await isExpensive in await networkReachability.expensiveChanges() {
                XCTAssertFalse(isExpensive)
                expectation.fulfill()
            }
        }
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newPath = MockPath(status: .satisfied, isExpensive: false)
            monitor.onPathUpdateCheck.argument?(newPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_expensiveChangesPublisher_whenCostChanges_shouldNotify() async {
        let path = MockPath(status: .satisfied, isExpensive: true)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "cost changed")
        networkReachability.expensiveChangesPublisher().sink { isExpensive in
            XCTAssertFalse(isExpensive)
            expectation.fulfill()
        }.store(in: &bag)
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newPath = MockPath(status: .satisfied, isExpensive: false)
            monitor.onPathUpdateCheck.argument?(newPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_constrainedChanges_whenRestrictionsChanges_shouldNotify() async {
        let path = MockPath(status: .satisfied, isConstrained: true)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "restriction changed")
        Task.detached {
            for await isConstrained in await networkReachability.constrainedChanges() {
                XCTAssertFalse(isConstrained)
                expectation.fulfill()
            }
        }
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newPath = MockPath(status: .satisfied, isConstrained: false)
            monitor.onPathUpdateCheck.argument?(newPath)
        }
        await fulfillment(of: [expectation])
    }

    @MainActor
    func test_constrainedChangesPublisher_whenRestrictionsChanges_shouldNotify() async {
        let path = MockPath(status: .satisfied, isConstrained: true)
        let monitor = MockPathMonitor(path: path)
        let networkReachability = Reachability(monitor: monitor)
        let expectation = XCTestExpectation(description: "restriction changed")
        networkReachability.constrainedChangesPublisher().sink { isConstrained in
            XCTAssertFalse(isConstrained)
            expectation.fulfill()
        }.store(in: &bag)
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let newPath = MockPath(status: .satisfied, isConstrained: false)
            monitor.onPathUpdateCheck.argument?(newPath)
        }
        await fulfillment(of: [expectation])
    }
}
