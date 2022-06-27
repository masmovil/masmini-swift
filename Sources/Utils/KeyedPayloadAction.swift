import Foundation

public protocol KeyedPayloadAction {
    associatedtype Payload
    associatedtype Key: Hashable

    init(task: Task<Payload>, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }

public protocol KeyedEmptyAction: Action & PayloadAction where Payload == EmptyPayload {
    associatedtype Key: Equatable

    init(task: Task<Payload>, key: Key)
}
