import Foundation

public final class FakeMethodCall<P, R> {
    private struct ReturnRule {
        let predicate: (P) -> Bool
        let value: R
    }
    public var wasCalled: Bool { callHistory.count > 0 }
    public var args: P? { callHistory.last?.args }
    public var callCount: Int { callHistory.count }
    
    private var returnRules: [ReturnRule]
    public struct Call {
        public let args: P
        public let returnValue: R
    }
    public private(set) var callHistory = [Call]()
    
    public init(_ parameterType: P.Type, _ returnValue: R) {
        self.returnRules = [ReturnRule(predicate: { _ in true }, value: returnValue)]
    }
    
    public func fake(_ parameters: P) -> R {
        let returnValue = determineReturnValue(for: parameters)
        let call = Call(args: parameters, returnValue: returnValue)
        callHistory.append(call)
        return returnValue
    }
    
    @discardableResult
    public func `return`(_ value: R, if predicate: @escaping (P) -> Bool) -> FakeMethodCall {
        let rule = ReturnRule(predicate: predicate, value: value)
        returnRules.append(rule)
        return self
    }
    
    @discardableResult
    public func `return`<Q: Equatable>(_ value: R, if keyPath: KeyPath<P, Q>, equals compareValue: Q) -> FakeMethodCall {
        self.return(value, if: { $0[keyPath: keyPath] == compareValue })
    }
    
    @discardableResult
    public func `return`(_ value: R) -> FakeMethodCall {
        let rule = ReturnRule(predicate: { _ in true }, value: value)
        returnRules.append(rule)
        return self
    }
    
    public func resetCallHistory() {
        callHistory = []
    }
}

private extension FakeMethodCall {
    func determineReturnValue(for parameters: P) -> R {
        returnRules.last(where: { $0.predicate(parameters) }).map { $0.value }!
    }
}
