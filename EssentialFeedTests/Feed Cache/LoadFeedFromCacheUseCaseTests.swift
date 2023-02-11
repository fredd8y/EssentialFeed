//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 11/02/23.
//

import EssentialFeed
import XCTest

class LoadFeedFromCacheUseCaseTests: XCTestCase {
	// MARK: Internal

	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_load_requestsCacheRetrieval() {
		let (sut, store) = makeSUT()

		sut.load { _ in }

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_failsOnRetrievalError() {
		let (sut, store) = makeSUT()
		let retrievalError = anyNSError()

		expect(sut, toCompleteWith: .failure(retrievalError)) {
			store.completeRetrieval(with: retrievalError)
		}
	}

	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrievalWithEmptyCache()
		}
	}

	// MARK: Private

	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expect(
		_ sut: LocalFeedLoader,
		toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for load completion")

		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedImages), .success(expectedImages)):
				XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1)
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
