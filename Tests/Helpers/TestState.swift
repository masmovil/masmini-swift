import Foundation
import Mini

struct TestState: StateType {
    public let testTask: Task<Void, TestError>
    public let counter: Int

    public init(testTask: Task<Void, TestError> = .requestIdle(),
                counter: Int = 0) {
        self.testTask = testTask
        self.counter = counter
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        return true
    }
}
