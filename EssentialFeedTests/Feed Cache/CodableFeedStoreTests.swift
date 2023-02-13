//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 12/02/23.
//

import EssentialFeed
import XCTest

// MARK: - CodableFeedStore

class CodableFeedStore {
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date

		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}

	private struct CodableFeedImage: Codable {
		// MARK: Lifecycle

		init(_ localFeedImage: LocalFeedImage) {
			id = localFeedImage.id
			description = localFeedImage.description
			location = localFeedImage.location
			url = localFeedImage.url
		}

		// MARK: Internal

		var local: LocalFeedImage {
			return LocalFeedImage(id: id, description: description, location: location, url: url)
		}

		// MARK: Private

		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
	}

	// MARK: Lifecycle

	init(storeURL: URL) {
		self.storeURL = storeURL
	}

	// MARK: Internal

	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
			completion(.empty)
			return
		}
		do {
			let decoder = JSONDecoder()
			let decoded = try decoder.decode(Cache.self, from: data)
			completion(.found(feed: decoded.localFeed, timestamp: decoded.timestamp))
		} catch {
			completion(.failure(error))
		}
	}

	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		let encoder = JSONEncoder()
		let cache = Cache(feed: feed.map { CodableFeedImage($0) }, timestamp: timestamp)
		let encoded = try! encoder.encode(cache)
		try! encoded.write(to: storeURL)
		completion(nil)
	}

	// MARK: Private

	private let storeURL: URL
}

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

	// MARK: Private
	
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) {
		let exp = expectation(description: "Wait for cache retrieval")
		sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)
	}
	
	private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
	
	private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
	
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}
}
