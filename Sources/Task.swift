import Foundation

public typealias AnyTask = Task<Any, Error>
public typealias EmptyTask<E: Error> = Task<Void, E>

public protocol TaskType {
    var isIdle: Bool { get }
    var isRunning: Bool { get }
    var isRecentlySucceeded: Bool { get }
    var isTerminal: Bool { get }
    var isSuccessful: Bool { get }
    var isFailure: Bool { get }
}

public class Task<T, E: Error>: TaskType, Equatable, CustomDebugStringConvertible {
    public let status: Status
    public let started: Date
    public let expiration: Expiration
    public let data: T?
    public let tag: String?
    public let progress: Decimal?
    public let error: E?

    public required init(status: Status = .idle,
                         started: Date = Date(),
                         expiration: Expiration = .immediately,
                         tag: String? = nil,
                         progress: Decimal? = nil) {
        self.status = status
        self.started = started
        self.expiration = expiration
        self.tag = tag
        self.progress = progress

        switch status {
        case .success(let payload):
            self.error = nil
            self.data = payload

        case .failure(let error):
            self.error = error
            self.data = nil

        default:
            self.data = nil
            self.error = nil
        }
    }

    public var isIdle: Bool {
        switch status {
        case .idle:
            return true

        default:
            return false
        }
    }

    public var isRunning: Bool {
        switch status {
        case .running:
            return true

        default:
            return false
        }
    }

    public var isRecentlySucceeded: Bool {
        switch status {
        case .success where started.timeIntervalSinceNow + expiration.value >= 0:
            return true

        default:
            return false
        }
    }

    public var isTerminal: Bool {
        switch status {
        case .success, .failure:
            return true

        default:
            return false
        }
    }

    public var isSuccessful: Bool {
        switch status {
        case .success:
            return true

        default:
            return false
        }
    }

    public var isFailure: Bool {
        switch status {
        case .failure:
            return true

        default:
            return false
        }
    }

    public static func requestIdle(tag: String? = nil) -> Self {
        .init(status: .idle, tag: tag)
    }

    public static func requestRunning(tag: String? = nil) -> Self {
        .init(status: .running, tag: tag)
    }

    public static func requestFailure(_ error: E, tag: String? = nil) -> Self {
        .init(status: .failure(error: error), tag: tag)
    }

    public static func requestSuccess(_ payload: T, expiration: Expiration = .immediately, tag: String? = nil) -> Self {
        .init(status: .success(payload: payload), expiration: expiration, tag: tag)
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        let tagPrint: String
        if let tag = tag {
            tagPrint = tag
        } else {
            tagPrint = "nil"
        }

        return """
        🚀 Task: status: \(status), started: \(started), tag: \(tagPrint)
        data: \(String(describing: data)), progress: \(String(describing: progress)) error: \(String(describing: error))
        """
    }

    // MARK: Equatable
    public static func ==<T, E> (lhs: Task<T, E>, rhs: Task<T, E>) -> Bool {
        lhs.status == rhs.status &&
            lhs.started == rhs.started &&
            lhs.progress == rhs.progress
    }
}

public extension Task where T == Void {
    static func requestSuccess(expiration: Expiration = .immediately, tag: String? = nil) -> Self {
        .init(status: .success(payload: ()), expiration: expiration, tag: tag)
    }
}
