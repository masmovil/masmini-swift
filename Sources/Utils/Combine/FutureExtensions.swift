import Combine
import Foundation

public extension Future where Failure: Error {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: TypedTask<Output>.Expiration = .immediately,
                                        on dispatcher: Dispatcher,
                                        fillOnError errorPayload: A.Payload? = nil)
    -> Cancellable where A.Payload == Output {
        sink { completion in
            switch completion {
            case .failure(let error):
                let failedTask = TypedTask<Output>(status: .failure(error: error))
                let action = A(task: failedTask, payload: errorPayload)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let successTask = TypedTask(status: .success(payload: payload), expiration: expiration)
            let action = A(task: successTask, payload: payload)
            dispatcher.dispatch(action)
        }
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: TypedTask<Output>.Expiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher,
                                             fillOnError errorPayload: A.Payload? = nil)
    -> Cancellable where A.Payload == Output {
        sink { completion in
            switch completion {
            case .failure(let error):
                let failedTask = TypedTask<Output>(status: .failure(error: error), tag: "\(key)")
                let action = A(task: failedTask, payload: errorPayload, key: key)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let successTask = TypedTask(status: .success(payload: payload), expiration: expiration, tag: "\(key)")
            let action = A(task: successTask, payload: payload, key: key)
            dispatcher.dispatch(action)
        }
    }
}

public extension Future where Output == Never {
    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: TypedTask<A.Payload>.Expiration = .immediately,
                                  on dispatcher: Dispatcher)
    -> Cancellable {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error))
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .requestSuccess(expiration))
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: TypedTask<A.Payload>.Expiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
    -> Cancellable {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error), key: key)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .requestSuccess(expiration, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }
}
