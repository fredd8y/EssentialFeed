//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 09/02/23.
//

import EssentialFeed
import XCTest

// MARK: - CacheFeedUseCaseTests

final class CacheFeedUseCaseTests: XCTestCase {
	// MARK: Internal

	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_save_requestsCacheDeletion() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()

		sut.save(items) { _ in }

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}

	func test_save_deosNotRequestCacheInsertionOnDeletionError() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()

		sut.save(items) { _ in }
		store.completeDeletion(with: deletionError)

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}

	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT(currentDate: { timestamp })

		sut.save(items) { _ in }
		store.completeDeletionSuccessfully()

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
	}

	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()

		expect(sut, toCompleteWithError: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}

	func test_save_failsOnInsertionError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()

		expect(sut, toCompleteWithError: insertionError) {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		}
	}

	func test_save_succeedOnSuccessfulCacheInsertion() {
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWithError: nil) {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		}
	}

	func test_save_doesNoteDeliverDeletionErrorAfterSUTInstanceHasBeenDellocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save([uniqueItem()]) { receivedResults.append($0) }

		sut = nil

		store.completeDeletion(with: anyNSError())

		XCTAssertTrue(receivedResults.isEmpty)
	}

	func test_save_doesNoteDeliverInsertionErrorAfterSUTInstanceHasBeenDellocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save([uniqueItem()]) { receivedResults.append($0) }

		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())

		XCTAssertTrue(receivedResults.isEmpty)
	}

	// MARK: Private

	private class FeedStoreSpy: FeedStore {
		typealias DeletionCompletion = (Error?) -> Void
		typealias InsertionCompletion = (Error?) -> Void

		// MARK: Internal

		enum ReceivedMessage: Equatable {
			case deleteCachedFeed
			case insert([FeedItem], Date)
		}

		private(set) var receivedMessages = [ReceivedMessage]()

		func deleteCacheFeed(completion: @escaping DeletionCompletion) {
			deletionCompletions.append(completion)
			receivedMessages.append(.deleteCachedFeed)
		}

		func completeDeletion(with error: Error, at index: Int = 0) {
			deletionCompletions[index](error)
		}

		func completeDeletionSuccessfully(at index: Int = 0) {
			deletionCompletions[index](nil)
		}

		func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessages.append(.insert(items, timestamp))
		}

		func completeInsertion(with error: Error, at index: Int = 0) {
			insertionCompletions[index](error)
		}

		func completeInsertionSuccessfully(at index: Int = 0) {
			insertionCompletions[index](nil)
		}

		// MARK: Private

		private var deletionCompletions = [DeletionCompletion]()

		private var insertionCompletions = [InsertionCompletion]()
	}

	// MARK: - Helpers

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
		toCompleteWithError expectedError: NSError?,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for save completion")

		var receivedError: Error?
		sut.save([uniqueItem()]) { error in
			receivedError = error
			exp.fulfill()
		}
		action()

		wait(for: [exp], timeout: 1)

		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}

	private func uniqueItem() -> FeedItem {
		return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}

	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
