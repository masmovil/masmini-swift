import Foundation

public struct EmptyPayload: Equatable {
    internal init() {
    }

    public static var none: EmptyPayload {
        EmptyPayload()
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}
