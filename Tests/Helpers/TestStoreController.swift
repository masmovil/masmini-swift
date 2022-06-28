import Foundation
import Mini
import RxSwift
import XCTest

class TestStoreController: Disposable {
    public func dispose() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {
    func reducerGroup(expectation: XCTestExpectation? = nil) -> ReducerGroup {
        ReducerGroup { [
            Reducer(of: TestAction.self, on: self.dispatcher) { action in
                self.state = TestState(testTask: .requestSuccess(), counter: action.counter)
                expectation?.fulfill()
            }
        ]
        }
    }
}
