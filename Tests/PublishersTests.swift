import Combine
@testable import Mini
import XCTest

class PublishersTests: XCTestCase {
    var taskSuccess1: Task<String, TestError> = .requestSuccess("hola")
    var taskSuccess2: Task<String, TestError> = .requestSuccess("chau")
    var taskFailure1: Task<String, TestError> = .requestFailure(.berenjenaError)
    var taskFailure2: Task<String, TestError> = .requestFailure(.berenjenaError)
    var taskRunning1: Task<String, TestError> = .requestRunning()
    var taskIdle1: Task<String, TestError> = .requestIdle()

    func test_combining_two_success_tasks() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait for async process")

        Publishers
            .CombineLatest(Just(taskSuccess1), Just(taskSuccess2))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isSuccessful)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_combining_two_success_tasks_with_one_failure() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait for async process")

        Publishers
            .CombineLatest3(Just(taskSuccess1), Just(taskSuccess2), Just(taskFailure1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isFailure)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_combining_two_success_tasks_with_two_failures() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait for async process")

        Publishers
            .CombineLatest4(Just(taskSuccess1), Just(taskSuccess2), Just(taskFailure1), Just(taskFailure2))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isFailure)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_combining_two_success_tasks_with_one_running() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait for async process")

        Publishers
            .CombineLatest3(Just(taskSuccess1), Just(taskSuccess2), Just(taskRunning1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_combining_two_success_in_array() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait for async process")

        Just([taskSuccess1, taskSuccess2])
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isSuccessful)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_combining_idle_tasks() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait for async process")

        Just([taskIdle1, taskIdle1, taskIdle1, taskIdle1, taskIdle1])
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isIdle)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }
}
