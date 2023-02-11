//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 11/02/23.
//

import Foundation
import EssentialFeed

internal class FeedStoreSpy: FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	
	// MARK: Internal
	
	enum ReceivedMessage: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
	}
	
	private(set) var receivedMessages = [ReceivedMessage]()
	
	internal func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		deletionCompletions.append(completion)
		receivedMessages.append(.deleteCachedFeed)
	}
	
	internal func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	internal func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
	
	internal func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		insertionCompletions.append(completion)
		receivedMessages.append(.insert(feed, timestamp))
	}
	
	internal func completeInsertion(with error: Error, at index: Int = 0) {
		insertionCompletions[index](error)
	}
	
	internal func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletions[index](nil)
	}
	
	// MARK: Private
	
	private var deletionCompletions = [DeletionCompletion]()
	
	private var insertionCompletions = [InsertionCompletion]()
	}
