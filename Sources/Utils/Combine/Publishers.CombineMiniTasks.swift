import Combine
import Foundation

public extension Publisher where Failure == Never {
    func combineMiniTasks<T1: TaskType, T2: TaskType>() -> Publishers.CombineMiniTasks<Self, T1.Failure>
    where Output == (T1, T2), T1.Failure == T2.Failure {
        Publishers.CombineMiniTasks(upstream: self)
    }

    func combineMiniTasks<T1: TaskType, T2: TaskType, T3: TaskType>() -> Publishers.CombineMiniTasks<Self, T1.Failure>
    where Output == (T1, T2, T3), T1.Failure == T2.Failure {
        Publishers.CombineMiniTasks(upstream: self)
    }

    func combineMiniTasks<T1: TaskType, T2: TaskType, T3: TaskType, T4: TaskType>() -> Publishers.CombineMiniTasks<Self, T1.Failure>
    where Output == (T1, T2, T3, T4), T1.Failure == T2.Failure {
        Publishers.CombineMiniTasks(upstream: self)
    }

    func combineMiniTasks<T: TaskType>() -> Publishers.CombineMiniTasks<Self, T.Failure>
    where Output == [T] {
        Publishers.CombineMiniTasks(upstream: self)
    }
}

public extension Publishers {
    /// Create a `Publisher` that connect an Upstream (Another publisher) that emits `Task` (Array or Tuples)
    /// The Output of this Publisher always is a combined `Task`
    struct CombineMiniTasks<Upstream: Publisher, TaskFailure: Error>: Publisher {
        public typealias Output = EmptyTask<TaskFailure>
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
            let tasks: [any TaskType]
            switch input {
            case let inputTuple2 as (any TaskType, any TaskType):
                tasks = [inputTuple2.0, inputTuple2.1]

            case let inputTuple3 as (any TaskType, any TaskType, any TaskType):
                tasks = [inputTuple3.0, inputTuple3.1, inputTuple3.2]

            case let inputTuple4 as (any TaskType, any TaskType, any TaskType, any TaskType):
                tasks = [inputTuple4.0, inputTuple4.1, inputTuple4.2, inputTuple4.3]

            case let inputTasks as [any TaskType]:
                tasks = inputTasks

            default:
                return .none
            }

            if let failureTask = tasks.first(where: { $0.isFailure }), let failure = failureTask.error as? Output.Failure {
                return downstream.receive(.requestFailure(failure))
            }

            if tasks.map({ $0.isRunning }).contains(true) {
                return downstream.receive(.requestRunning())
            }

            if !tasks.map({ $0.isSuccessful }).contains(false) {
                return downstream.receive(.requestSuccess())
            }

            return downstream.receive(.requestIdle())
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
