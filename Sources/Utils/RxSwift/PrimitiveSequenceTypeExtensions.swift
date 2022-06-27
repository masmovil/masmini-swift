import Foundation
import RxSwift

public extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: Task<Element>.Expiration = .immediately,
                                        on dispatcher: Dispatcher)
        -> Disposable where A.Payload == Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                let successTask = Task(status: .success(payload: payload), expiration: expiration)
                let action = A(task: successTask)
                dispatcher.dispatch(action)
            },
            onFailure: { error in
                let failedTask = Task<Element>(status: .failure(error: error))
                let action = A(task: failedTask)
                dispatcher.dispatch(action)
            }
        )
        return subscription
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: Task<Element>.Expiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher)
        -> Disposable where A.Payload == Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                let successTask = Task(status: .success(payload: payload), expiration: expiration, tag: "\(key)")
                let action = A(task: successTask, key: key)
                dispatcher.dispatch(action)
            },
            onFailure: { error in
                let failedTask = Task<Element>(status: .failure(error: error), tag: "\(key)")
                let action = A(task: failedTask, key: key)
                dispatcher.dispatch(action)
            }
        )
        return subscription
    }

    func action<A: CompletableAction>(_ action: A.Type,
                                      expiration: Task<Element>.Expiration = .immediately)
        -> Single<A> where A.Payload == Element {
        Single.create { single in
            let subscription = self.subscribe(
                onSuccess: { payload in
                    let successTask = Task(status: .success(payload: payload), expiration: expiration)
                    let action = A(task: successTask)
                    single(.success(action))
                },
                onFailure: { error in
                    let failedTask = Task<Element>(status: .failure(error: error))
                    let action = A(task: failedTask)
                    single(.success(action))
                }
            )
            return Disposables.create([subscription])
        }
    }
}

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Never {
    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: Task<A.Payload>.Expiration = .immediately,
                                  on dispatcher: Dispatcher)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                let action = A(task: .requestSuccess(expiration))
                dispatcher.dispatch(action)

            case .error(let error):
                let action = A(task: .requestFailure(error))
                dispatcher.dispatch(action)
            }
        }
        return subscription
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: Task<A.Payload>.Expiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                let action = A(task: .requestSuccess(expiration, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)

            case .error(let error):
                let action = A(task: .requestFailure(error, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)
            }
        }
        return subscription
    }

    func action<A: EmptyAction>(_ action: A.Type,
                                expiration: Task<A.Payload>.Expiration = .immediately)
        -> Single<A> {
        Single.create { single in
            let subscription = self.subscribe { event in
                switch event {
                case .completed:
                    let action = A(task: .requestSuccess(expiration))
                    single(.success(action))

                case .error(let error):
                    let action = A(task: .requestFailure(error))
                    single(.success(action))
                }
            }
            return Disposables.create([subscription])
        }
    }
}
