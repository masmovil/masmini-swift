import Foundation

public protocol PayloadAction {
    associatedtype TaskPayload: Equatable
    associatedtype TaskError: Error

    var task: Task<TaskPayload, TaskError> { get }

    init(task: Task<TaskPayload, TaskError>)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction {
    associatedtype TaskPayload = None

    init(task: EmptyTask<TaskError>)
}

public protocol AttributedAction: Action & PayloadAction {
    associatedtype Attribute: Equatable
    var attribute: Attribute { get }

    init(task: Task<TaskPayload, TaskError>, attribute: Attribute)
}

extension AttributedAction {
    public init(task: Task<TaskPayload, TaskError>) {
        fatalError("You must use init(task:attribute:)")
    }
}
