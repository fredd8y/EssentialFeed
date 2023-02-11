//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 11/02/23.
//

import EssentialFeed
import Foundation

class FeedStoreSpy: FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void

	// MARK: Internal

	enum ReceivedMessage: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
		case retrieve
	}

	private(set) var receivedMessages = [ReceivedMessage]()

	func retrieve() {
		receivedMessages.append(.retrieve)
	}

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

	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		insertionCompletions.append(completion)
		receivedMessages.append(.insert(feed, timestamp))
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
