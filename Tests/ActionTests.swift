@testable import Mini
import XCTest

final class ActionTests: XCTestCase {
    func test_actions() {
        let payloadTask: Task<String, TestError> = .idle()
        let emptyTask: EmptyTask<TestError> = .running()

        let emptyAction = TestEmptyAction(task: emptyTask)
        XCTAssertEqual(emptyAction.task, emptyTask)

        let completableAction = TestCompletableAction(task: payloadTask)
        XCTAssertEqual(completableAction.task, payloadTask)

        let keyedCompletableAction = TestKeyedCompletableAction(task: payloadTask, key: "1")
        XCTAssertTrue(keyedCompletableAction.task == payloadTask)
        XCTAssertTrue(keyedCompletableAction.key == "1")

        let keyedEmptyAction = TestKeyedEmptyAction(task: emptyTask, key: "1")
        XCTAssertTrue(keyedEmptyAction.task == emptyTask)
        XCTAssertTrue(keyedEmptyAction.key == "1")

        let attributedAction = TestAttributedAction(attribute: "asd")
        XCTAssertEqual(attributedAction.attribute, "asd")
    }
}
