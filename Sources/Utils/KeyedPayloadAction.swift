import Foundation

public protocol KeyedPayloadAction {
    associatedtype TaskPayload
    associatedtype TaskError: Error
    associatedtype Key: Hashable

    var task: Task<TaskPayload, TaskError> { get }
    var key: Key { get }

    init(task: Task<TaskPayload, TaskError>, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }

public protocol KeyedEmptyAction: Action & KeyedPayloadAction {
    associatedtype TaskPayload = Void

    init(task: Task<TaskPayload, TaskError>, key: Key)
}
