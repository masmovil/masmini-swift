import Foundation

public protocol PayloadAction {
    associatedtype Payload

    init(task: Task<Payload>)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction where Payload == EmptyPayload {
    init(task: EmptyTask)
}
