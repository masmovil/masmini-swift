import Combine
@testable import Mini
import XCTest

extension PublishersTests {
    // Tuple2

    func test_combining_tuple_of_2_with_2_idle() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_2_with_2_idle")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest(Just(taskIdle1), Just(taskIdle1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isIdle)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_tuple_of_2_with_2_success() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_2_with_2_success")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest(Just(taskSuccess1), Just(taskSuccess2))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isSuccessful)
                XCTAssertEqual(combinedTask.payload, .init("hola", "chau"))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_tuple_of_2_with_1_success_1_running() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_2_with_1_success_1_running")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest(Just(taskSuccess1), Just(taskRunning1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_tuple_of_2_with_1_success_1_failure() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_2_with_1_success_1_failure")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest(Just(taskSuccess1), Just(taskFailure1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isFailure)
                XCTAssertEqual(combinedTask.error, .berenjenaError)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    // Tuple 3

    func test_combining_tuple_of_3_with_2_success_1_failure() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_3_with_2_success_1_failure")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest3(Just(taskSuccess1), Just(taskSuccess2), Just(taskFailure1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isFailure)
                XCTAssertEqual(combinedTask.error, .berenjenaError)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_tuple_of_3_with_2_success_1_running() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_3_with_2_success_1_running")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest3(Just(taskSuccess1), Just(taskSuccess2), Just(taskRunning1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    // Tuple 4

    func test_combining_tuple_of_4_with_2_success_1_failure_1_running() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_4_with_2_success_1_failure_1_running")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest4(Just(taskSuccess1), Just(taskSuccess2), Just(taskFailure1), Just(taskRunning1))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_tuple_of_4_with_2_success_2_failure() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_4_with_2_success_2_failure")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest4(Just(taskSuccess1), Just(taskSuccess2), Just(taskFailure1), Just(taskFailure2))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isFailure)
                XCTAssertEqual(combinedTask.error, .berenjenaError)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_tuple_of_4_with_4_success() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_tuple_of_4_with_4_success")
        expectation.expectedFulfillmentCount = 1

        Publishers
            .CombineLatest4(Just(taskSuccess1), Just(taskSuccess2), Just(taskSuccess1), Just(taskSuccess2))
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isSuccessful)
                XCTAssertEqual(combinedTask.payload, .init("hola", "chau", "hola", "chau"))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    // Array

    func test_combining_two_success_in_array() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_two_success_in_array")
        expectation.expectedFulfillmentCount = 1

        Just([taskSuccess1, taskSuccess2])
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isSuccessful)
                XCTAssertEqual(combinedTask.payload, ["hola", "chau"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_one_success_one_failure_in_array() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_one_success_one_failure_in_array")
        expectation.expectedFulfillmentCount = 1

        Just([taskSuccess1, taskFailure1])
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isFailure)
                XCTAssertEqual(combinedTask.error, .berenjenaError)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_one_success_one_running_in_array() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_one_success_one_running_in_array")
        expectation.expectedFulfillmentCount = 1

        Just([taskSuccess1, taskRunning1])
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_combining_idle_tasks_in_array() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_combining_idle_tasks_in_array")
        expectation.expectedFulfillmentCount = 1

        Just([taskIdle1, taskIdle1, taskIdle1, taskIdle1, taskIdle1])
            .combineMiniTasks()
            .sink { combinedTask in
                XCTAssertTrue(combinedTask.isIdle)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }
}
