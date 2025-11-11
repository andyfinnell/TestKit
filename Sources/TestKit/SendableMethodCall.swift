import Foundation
import os

public final class SendableMethodCall<P: Sendable, R: Sendable>: Sendable {
    public var wasCalled: Bool { callHistory.count > 0 }
    public var args: P? { callHistory.last?.args }
    public var callCount: Int { callHistory.count }
    public var callHistory: [Call] {
        memberData.withLock { $0.callHistory }
    }
    public struct Call: Sendable {
        public let args: P
        public let returnValue: R
    }
    private let memberData: OSAllocatedUnfairLock<MemberData>
    
    public init(_ parameterType: P.Type, _ returnValue: R) {
        memberData = OSAllocatedUnfairLock(uncheckedState: MemberData(returnRules: [ReturnRule(predicate: { _ in true }, value: returnValue)]))
    }
    
    public func fake(_ parameters: P) -> R {
        let returnValue = determineReturnValue(for: parameters)
        let call = Call(args: parameters, returnValue: returnValue)
        memberData.withLock {
            $0.callHistory.append(call)
        }
        return returnValue
    }

    public func fakeThrows<S, F: Error>(_ parameters: P) throws -> S where R == Result<S, F> {
        let returnValue = determineReturnValue(for: parameters)
        let call = Call(args: parameters, returnValue: returnValue)
        memberData.withLock {
            $0.callHistory.append(call)
        }
        
        switch returnValue {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }

    @discardableResult
    public func `return`(_ value: R, if predicate: @escaping @Sendable (P) -> Bool) -> SendableMethodCall {
        let rule = ReturnRule(predicate: predicate, value: value)
        memberData.withLock {
            $0.returnRules.append(rule)
        }
        return self
    }

    @discardableResult
    public func `return`(_ value: R, ifEqual expectedValue: P) -> SendableMethodCall where P: Equatable {
        self.return(value, if: { $0 == expectedValue })
    }

    @discardableResult
    public func `return`<Q: Equatable & Sendable>(_ value: R, if keyPath: KeyPath<P, Q> & Sendable, equals compareValue: Q) -> SendableMethodCall {
        self.return(value, if: { $0[keyPath: keyPath] == compareValue })
    }
    
    @discardableResult
    public func `return`(_ value: R) -> SendableMethodCall {
        self.return(value, if: { _ in true })
    }
    
    @discardableResult
    public func `return`<S, F: Error>(_ value: S, if predicate: @escaping @Sendable (P) -> Bool) -> SendableMethodCall where R == Result<S, F> {
        let rule = ReturnRule(predicate: predicate, value: .success(value))
        memberData.withLock {
            $0.returnRules.append(rule)
        }
        return self
    }

    @discardableResult
    public func `return`<S, F: Error, Q: Equatable & Sendable>(_ value: S, if keyPath: KeyPath<P, Q> & Sendable, equals compareValue: Q) -> SendableMethodCall where R == Result<S, F> {
        self.return(value, if: { $0[keyPath: keyPath] == compareValue })
    }

    @discardableResult
    public func `return`<S, F: Error>(_ value: S, ifEqual compareValue: P) -> SendableMethodCall where R == Result<S, F>, P: Equatable {
        self.return(value, if: { $0 == compareValue })
    }

    @discardableResult
    public func `return`<S, F: Error>(_ value: S) -> SendableMethodCall where R == Result<S, F> {
        self.return(value, if: { _ in true })
    }

    @discardableResult
    public func `throw`<S, F: Error>(_ error: F, if predicate: @escaping @Sendable (P) -> Bool) -> SendableMethodCall where R == Result<S, F> {
        let rule = ReturnRule(predicate: predicate, value: .failure(error))
        memberData.withLock {
            $0.returnRules.append(rule)
        }
        return self
    }

    @discardableResult
    public func `throw`<Q: Equatable & Sendable, S, F: Error>(_ error: F, if keyPath: KeyPath<P, Q> & Sendable, equals compareValue: Q) -> SendableMethodCall where R == Result<S, F> {
        self.throw(error, if: { $0[keyPath: keyPath] == compareValue })
    }

    @discardableResult
    public func `throw`<S, F: Error>(_ error: F) -> SendableMethodCall where R == Result<S, F> {
        self.throw(error, if: { _ in true })
    }

    @discardableResult
    public func `throw`<S>() -> SendableMethodCall where R == Result<S, Error> {
        self.throw(FakeError(), if: { _ in true })
    }

    public func resetCallHistory() {
        memberData.withLock {
            $0.callHistory = []
        }
    }
    
    func wasCalled(where predicate: @Sendable (P) -> Bool) -> Bool {
        memberData.withLock {
            $0.callHistory.contains(where: { predicate($0.args)  })
        }
    }
}

private extension SendableMethodCall {
    struct ReturnRule: Sendable {
        let predicate: @Sendable (P) -> Bool
        let value: R
    }

    struct MemberData {
        var returnRules: [ReturnRule]
        var callHistory = [Call]()
    }
    
    func determineReturnValue(for parameters: P) -> R {
        memberData.withLock {
            $0.returnRules.last(where: { $0.predicate(parameters) }).map { $0.value }!
        }
    }
}
