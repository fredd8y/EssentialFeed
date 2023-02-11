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
		
		sut.load() { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_failsOnRetrievalError() {
		let (sut, store) = makeSUT()
		
		let exp = expectation(description: "Wait for load completion")
		let retrievalError = anyNSError()
		
		var receivedError: Error?
		sut.load() { result in
			switch result {
			case let .failure(error):
				receivedError = error
			default:
				XCTFail("Expected failure got \(result) instead")
			}
			exp.fulfill()
		}
		
		store.completeRetrieval(with: retrievalError)
		
		wait(for: [exp], timeout: 1)
		
		XCTAssertEqual(receivedError as NSError?, retrievalError)
	}
	
	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		let exp = expectation(description: "Wait for save completion")
		
		var receivedImages: [FeedImage]?
		sut.load { result in
			switch result {
			case let .success(feed):
				receivedImages = feed
			default:
				XCTFail("Expected success, got \(result) instead")
			}
			exp.fulfill()
		}

		store.completeRetrievalWithEmptyCache()

		wait(for: [exp], timeout: 1)

		XCTAssertEqual(receivedImages, [])
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
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
