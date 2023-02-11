//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 09/02/23.
//

import Foundation

// MARK: - FeedStore

public enum RetrieveCachedFeedResult {
	case empty
	case found(feed: [LocalFeedImage], timestamp: Date)
	case failure(Error)
}

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void

	func deleteCacheFeed(completion: @escaping DeletionCompletion)
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
	func retrieve(completion: @escaping RetrievalCompletion)
}
