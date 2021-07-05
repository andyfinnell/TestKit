import Foundation
import XCTest
import Combine

public extension XCTestCase {
    enum TestCaseError: Error {
        case unfinishedPublisher
        case noValue
    }
    
    func waitAll<P: Publisher>(for publisher: P) throws -> [P.Output] {
        let theExpectation = expectation(description: "wait for publisher")
        var cancellables = Set<AnyCancellable>()
        var outputs = [P.Output]()
        var failure: P.Failure?
        var isComplete = false
        publisher.sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                failure = error
            }
            isComplete = true
            theExpectation.fulfill()
        }, receiveValue: { output in
            outputs.append(output)
        }).store(in: &cancellables)
        
        wait(for: [theExpectation], timeout: 1.0)
        
        guard isComplete else {
            throw TestCaseError.unfinishedPublisher
        }
        
        if let error = failure {
            throw error
        }
        
        return outputs
    }
    
    func waitLast<P: Publisher>(for publisher: P) throws -> P.Output {
        guard let last = try waitAll(for: publisher).last else {
            throw TestCaseError.noValue
        }
        return last
    }
}

