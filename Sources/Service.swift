import Foundation

public typealias ServiceChain = (Action, Chain) -> Void

public protocol Service {
    var id: UUID { get }
    var perform: ServiceChain { get }
    func stateWasReplayed(state: any State)
}
