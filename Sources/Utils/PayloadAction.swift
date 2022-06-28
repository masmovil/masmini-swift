import Foundation

public protocol PayloadAction {
    associatedtype TaskPayload
    associatedtype TaskError: Error

    init(task: Task<TaskPayload, TaskError>)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction {
    associatedtype TaskPayload = Void

    init(task: EmptyTask<TaskError>)
}
