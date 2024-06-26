import Foundation

public typealias Next = (Action) -> Action

public protocol Chain {
    var proceed: Next { get }
}

public final class ForwardingChain: Chain {
    private let next: Next

    public var proceed: Next {
        { self.next($0) }
    }

    public init(next: @escaping Next) {
        self.next = next
    }
}

public final class RootChain: Chain {
    private let map: SubscriptionMap

    public var proceed: Next {
        { action in
            if let set = self.map[action.innerTag] {
                set?.forEach { sub in
                    sub.on(action)
                }
            }
            return action
        }
    }

    public init(map: SubscriptionMap) {
        self.map = map
    }
}
