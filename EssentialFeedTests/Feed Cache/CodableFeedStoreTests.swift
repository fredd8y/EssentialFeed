//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 12/02/23.
//

import EssentialFeed
import XCTest

// MARK: - CodableFeedStoreTests

class CodableFeedStoreTests: XCTestCase {
	// MARK: Internal

	override func setUp() {
		super.setUp()

		setupEmptyStoreState()
	}

	override func tearDown() {
		super.tearDown()

		undoStoresideEffects()
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		
		expect(sut, toRetrieve: .empty)
	}

	func test_retrieve_hasNoSideEffectOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieveTwice: .empty)
	}

	func test_retrieve_deliversFoundValueOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()
		
		let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
		
		XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}

	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed, timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
	}
	
	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = cachesDirectory()
		let sut = makeSUT(storeURL: noDeletePermissionURL)
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
		expect(sut, toRetrieve: .empty)
	}
	
	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()
		var completedOperationsInOrder = [XCTestExpectation]()
		
		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Operation 2")
		sut.deleteCacheFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}
		
		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}
		
		waitForExpectations(timeout: 5.0)
		
		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
	}
	
	// MARK: Private
	
	@discardableResult
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache retrieval")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)
		return insertionError
	}
	
	private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { retrievedResult in
			switch (expectedResult, retrievedResult) {
			case (.empty, .empty), (.failure, .failure):
				break
			case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
				XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
				XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
			default:
				XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1)
	}
	
	private func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCacheFeed { receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 5)
		return deletionError
	}
	
	private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}

	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}

	private func undoStoresideEffects() {
		deleteStoreArtifacts()
	}

	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}
