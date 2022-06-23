import Combine
import Foundation

public extension Publisher where Output == (Task, Task) {
    func combineMiniTasks() -> Publishers.CombineMiniTasks<Self> {
        Publishers.CombineMiniTasks(upstream: self)
    }
}

public extension Publisher where Output == (Task, Task, Task) {
    func combineMiniTasks() -> Publishers.CombineMiniTasks<Self> {
        Publishers.CombineMiniTasks(upstream: self)
    }
}

public extension Publisher where Output == (Task, Task, Task, Task) {
    func combineMiniTasks() -> Publishers.CombineMiniTasks<Self> {
        Publishers.CombineMiniTasks(upstream: self)
    }
}

public extension Publisher where Output == [Task] {
    func combineMiniTasks() -> Publishers.CombineMiniTasks<Self> {
        Publishers.CombineMiniTasks(upstream: self)
    }
}

public extension Publishers {
    /// Create a `Publisher` that connect an Upstream (Another publisher) that emits `Task` (Array or Tuples)
    /// The Output of this Publisher always is a combined `Task`
    struct CombineMiniTasks<Upstream: Publisher>: Publisher {
        public typealias Output = Task
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        /// Here receive an Downstream (the destination) as a `Subscriber` and send always a `Task`
        public func receive<Downstream: Subscriber>(subscriber: Downstream)
        where Upstream.Failure == Downstream.Failure, Output == Downstream.Input {
            upstream.subscribe(Inner(downstream: subscriber))
        }
    }
}

extension Publishers.CombineMiniTasks {
    private struct Inner<Downstream: Subscriber>: Subscriber
    where Downstream.Input == Output, Downstream.Failure == Upstream.Failure {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure

        private let downstream: Downstream

        let combineIdentifier = CombineIdentifier()

        fileprivate init(downstream: Downstream) {
            self.downstream = downstream
        }

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            let tasks: [Task]
            switch input {
            case let inputTuple2 as (Task, Task):
                tasks = [inputTuple2.0, inputTuple2.1]

            case let inputTuple3 as (Task, Task, Task):
                tasks = [inputTuple3.0, inputTuple3.1, inputTuple3.2]

            case let inputTuple4 as (Task, Task, Task, Task):
                tasks = [inputTuple4.0, inputTuple4.1, inputTuple4.2, inputTuple4.3]

            case let inputTasks as [Task]:
                tasks = inputTasks

            default:
                return .none
            }

            if let failureTask = tasks.first(where: { $0.isFailure }) {
                return downstream.receive(failureTask)
            } else if tasks.map({ $0.isRunning }).contains(true) {
                return downstream.receive(.requestRunning())
            } else if !tasks.map({ $0.isSuccessful }).contains(false) {
                return downstream.receive(.requestSuccess())
            } else {
                return downstream.receive(Task())
            }
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
