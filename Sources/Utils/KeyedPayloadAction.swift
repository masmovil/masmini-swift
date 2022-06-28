import Foundation

public protocol KeyedPayloadAction {
    associatedtype TaskPayload
    associatedtype TaskError: Error
    associatedtype Key: Hashable

    init(task: Task<TaskPayload, TaskError>, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }

public protocol KeyedEmptyAction: Action & KeyedPayloadAction {
    associatedtype TaskPayload = Void

    init(task: Task<TaskPayload, TaskError>, key: Key)
}
