public extension Task {
    enum Status {
        case idle
        case running
        case success(payload: T)
        case failure(error: E)
    }
}

extension Task.Status: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.running, .running):
            return true

        // All new value or error must be treated as different.
        case (.success, .success), (.failure, .failure):
            return false

        default:
            return false
        }
    }
}
