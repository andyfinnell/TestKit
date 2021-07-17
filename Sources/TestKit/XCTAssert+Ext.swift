import Foundation
import XCTest

public func XCTAssertMethodWasCalled<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                           _ message: @autoclosure () -> String = "",
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
    XCTAssertTrue(methodCall().wasCalled, message(), file: file, line: line)
}

public func XCTAssertMethodWasNotCalled<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                              _ message: @autoclosure () -> String = "",
                                              file: StaticString = #filePath,
                                              line: UInt = #line) {
    XCTAssertFalse(methodCall().wasCalled, message(), file: file, line: line)
}

public func XCTAssertMethodWasCalled<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                           count: Int,
                                           _ message: @autoclosure () -> String = "",
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
    XCTAssertEqual(methodCall().callCount, count, message(), file: file, line: line)
}

public func XCTAssertMethodWasCalledWithArgEquals<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                                        _ arg: @autoclosure () -> P,
                                                        _ message: @autoclosure () -> String = "",
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) where P: Equatable {
    XCTAssertTrue(methodCall().wasCalled(where: { $0 == arg() }), message(), file: file, line: line)
}

public func XCTAssertMethodWasCalledWithArgEquals<P, R, T>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                                           _ keyPath: KeyPath<P, T>,
                                                           _ arg: @autoclosure () -> T,
                                                           _ message: @autoclosure () -> String = "",
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) where T: Equatable {
    XCTAssertTrue(methodCall().wasCalled(where: { $0[keyPath: keyPath] == arg() }), message(), file: file, line: line)
}

public func XCTAssertMethodWasCalledLastWithArgEquals<P, R>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                                            _ arg: @autoclosure () -> P,
                                                            _ message: @autoclosure () -> String = "",
                                                            file: StaticString = #filePath,
                                                            line: UInt = #line) where P: Equatable {
    XCTAssertEqual(methodCall().args, arg(), message(), file: file, line: line)
}

public func XCTAssertMethodWasCalledLastWithArgEquals<P, R, T>(_ methodCall: @autoclosure () -> FakeMethodCall<P, R>,
                                                               _ keyPath: KeyPath<P, T>,
                                                               _ arg: @autoclosure () -> T,
                                                               _ message: @autoclosure () -> String = "",
                                                               file: StaticString = #filePath,
                                                               line: UInt = #line) where T: Equatable {
    XCTAssertEqual(methodCall().args?[keyPath: keyPath], arg(), message(), file: file, line: line)
}

public func XCTAssertContains<S: Sequence>(_ sequence: @autoclosure () -> S,
                                           _ element: @autoclosure () -> S.Element,
                                           _ message: @autoclosure () -> String = "",
                                           file: StaticString = #filePath,
                                           line: UInt = #line) where S.Element: Equatable {
    XCTAssertTrue(sequence().contains(where: { $0 == element() }), message(), file: file, line: line)
}

public func XCTAssertIsEmpty<C: Collection>(_ collection: @autoclosure () -> C,
                                           _ message: @autoclosure () -> String = "",
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
    XCTAssertTrue(collection().isEmpty, message(), file: file, line: line)
}

public func XCTAssertHaveCount<C: Collection>(_ collection: @autoclosure () -> C,
                                              _ count: @autoclosure () -> Int,
                                              _ message: @autoclosure () -> String = "",
                                              file: StaticString = #filePath,
                                              line: UInt = #line) {
    XCTAssertEqual(collection().count, count(), message(), file: file, line: line)
}
