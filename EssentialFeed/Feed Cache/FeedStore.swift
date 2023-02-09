//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 09/02/23.
//

import Foundation

// MARK: - FeedStore

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void

	func deleteCacheFeed(completion: @escaping DeletionCompletion)

	func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
