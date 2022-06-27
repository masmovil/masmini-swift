import Combine
@testable import Mini
import RxSwift
import XCTest

final class DispatcherTests: XCTestCase {
    func test_subscription_count_with_combine() {
        let dispatcher = Dispatcher()
        var bag = Set<AnyCancellable>()

        XCTAssert(dispatcher.subscriptionCount == 0)

        dispatcher.subscribe { (_: OneTestAction) -> Void in }.store(in: &bag)
        dispatcher.subscribe { (_: OneTestAction) -> Void in }.store(in: &bag)

        print(dispatcher.subscriptionCount)

        XCTAssert(dispatcher.subscriptionCount == 2)

        bag.removeAll()

        XCTAssert(dispatcher.subscriptionCount == 0)
    }

    func test_subscription_count_with_rx() {
        let dispatcher = Dispatcher()
        let disposable = CompositeDisposable()

        XCTAssert(dispatcher.subscriptionCount == 0)

        _ = disposable.insert(dispatcher.subscribe { (_: OneTestAction) -> Void in })
        _ = disposable.insert(dispatcher.subscribe { (_: OneTestAction) -> Void in })

        print(dispatcher.subscriptionCount)

        XCTAssert(dispatcher.subscriptionCount == 2)

        disposable.dispose()

        XCTAssert(dispatcher.subscriptionCount == 0)
    }
    
    func test_send_value_to_dispatcher_from_future() {
        
    }

    func test_add_remove_service() {
        class TestService: ServiceType {
            func stateWasReplayed(state: StateType) {
            }

            var id = UUID()

            var actions = [Action]()

            private let expectation: XCTestExpectation

            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            var perform: ServiceChain {
                { action, _ -> Void in
                    self.actions.append(action)
                    self.expectation.fulfill()
                }
            }
        }

        let expectation = XCTestExpectation(description: "Service")

        let dispatcher = Dispatcher()

        let service = TestService(expectation)

        dispatcher.register(service: service)

        XCTAssert(service.actions.isEmpty == true)

        dispatcher.dispatch(OneTestAction(counter: 1))

        wait(for: [expectation], timeout: 5.0)

        XCTAssert(service.actions.count == 1)

        XCTAssert(service.actions.contains { $0 is OneTestAction } == true)

        dispatcher.unregister(service: service)

        service.actions.removeAll()

        dispatcher.dispatch(OneTestAction(counter: 1))

        XCTAssert(service.actions.isEmpty == true)
    }

    func test_replay_state() {
        class TestService: ServiceType {
            func stateWasReplayed(state: StateType) {
                self.expectation.fulfill()
            }

            var id = UUID()

            private let expectation: XCTestExpectation

            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            var perform: ServiceChain {
                { _, _ -> Void in
                }
            }
        }

        let expectation = XCTestExpectation(description: "Service")

        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())

        let service = TestService(expectation)

        dispatcher.register(service: service)

        store.replayOnce()

        wait(for: [expectation], timeout: 5.0)
    }
}
