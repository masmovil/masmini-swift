import Combine
import Foundation

public extension Future where Failure: Error {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: Task<Output, Failure>.Expiration = .immediately,
                                        on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let failedTask = Task<A.TaskPayload, A.TaskError>(status: .failure(error: error))
                let action = A(task: failedTask)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let successTask = Task<A.TaskPayload, A.TaskError>(status: .success(payload: payload), expiration: expiration)
            let action = A(task: successTask)
            dispatcher.dispatch(action)
        }
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: Task<Output, Failure>.Expiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let failedTask = Task<A.TaskPayload, A.TaskError>(status: .failure(error: error), tag: "\(key)")
                let action = A(task: failedTask, key: key)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let successTask = Task<A.TaskPayload, A.TaskError>(status: .success(payload: payload), expiration: expiration, tag: "\(key)")
            let action = A(task: successTask, key: key)
            dispatcher.dispatch(action)
        }
    }
}

public extension Future where Output == Void {
    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: Task<A.TaskPayload, A.TaskError>.Expiration = .immediately,
                                  on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error))
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .requestSuccess((), expiration: expiration))
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: Task<A.TaskPayload, A.TaskError>.Expiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error), key: key)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .requestSuccess((), expiration: expiration, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }
}
