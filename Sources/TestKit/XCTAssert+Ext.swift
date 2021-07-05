import Foundation
import XCTest

public func XCTAssertMethodWasCalled<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                           _ message: @autoclosure () -> String = "",
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
    XCTAssertTrue(methodCall().wasCalled, message(), file: file, line: line)
}

public func XCTAssertMethodWasCalled<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                           count: Int,
                                           _ message: @autoclosure () -> String = "",
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
    XCTAssertEqual(methodCall().callCount, count, message(), file: file, line: line)
}

public func XCTAssertMethodWasCalledWithArg<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                                  _ arg: @autoclosure () -> P,
                                                  _ message: @autoclosure () -> String = "",
                                                  file: StaticString = #filePath,
                                                  line: UInt = #line) where P: Equatable {
    XCTAssertEqual(methodCall().args, arg(), message(), file: file, line: line)
}

public func XCTAssertMethodWasCalledWithArg<P, R, T>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                                     _ keyPath: KeyPath<P, T>,
                                                     _ arg: @autoclosure () -> T,
                                                     _ message: @autoclosure () -> String = "",
                                                     file: StaticString = #filePath,
                                                     line: UInt = #line) where T: Equatable {
    XCTAssertEqual(methodCall().args?[keyPath: keyPath], arg(), message(), file: file, line: line)
}
