import Combine
import Foundation

public protocol StoreType {
    associatedtype State: StateType
    associatedtype StoreController: Cancellable

    var state: State { get set }
    var dispatcher: Dispatcher { get }
    var reducerGroup: ReducerGroup { get }
}

extension StoreType {
    /**
     Property responsible of reduce the `State` given a certain `Action` being triggered.
     ```
     public var reducerGroup: ReducerGroup {
        ReducerGroup {[
            Reducer(of: SomeAction.self, on: self.dispatcher) { (action: SomeAction)
                self.state = myCoolNewState
            },
            Reducer(of: OtherAction.self, on: self.dispatcher) { (action: OtherAction)
                // Needed work
                self.state = myAnotherState
                }
            }
        ]}
     ```
     - Note : The property has a default implementation which complies with the @_functionBuilder's current limitations, where no empty blocks can be produced in this iteration.
     */
    public var reducerGroup: ReducerGroup {
        ReducerGroup {
            []
        }
    }
}

public class Store<State: StateType, StoreController: Cancellable>: Publisher, StoreType {
    public typealias Output = State
    public typealias Failure = Never
    public typealias State = State
    public typealias StoreController = StoreController

    public let dispatcher: Dispatcher
    public var storeController: StoreController
    public var state: State {
        get {
            _state
        }
        set {
            queue.sync {
                if !newValue.isEqual(to: _state) {
                    _state = newValue
                    objectWillChange.send(state)
                }
            }
        }
    }
    public var initialState: State {
        _initialState
    }

    public init(_ state: State,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self._initialState = state
        self._state = state
        self.dispatcher = dispatcher
        self.objectWillChange = .init(state)
        self.storeController = storeController
        self.state = _initialState
    }

    public var reducerGroup: ReducerGroup {
        ReducerGroup {
            []
        }
    }

    public func replayOnce() {
        objectWillChange.send(state)

        dispatcher.stateWasReplayed(state: state)
    }

    public func reset() {
        state = initialState
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        objectWillChange.subscribe(subscriber)
    }

    private var objectWillChange: CurrentValueSubject<State, Never>
    private let queue = DispatchQueue(label: "atomic state")
    private var _initialState: State
    private var _state: State
}
