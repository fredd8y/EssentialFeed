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
	func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalFeedItem: Equatable {
	public init(
		id: UUID,
		description: String?,
		location: String?,
		imageURL: URL
	) {
		self.id = id
		self.description = description
		self.location = location
		self.imageURL = imageURL
	}
	
	// MARK: Internal
	
	public let id: UUID
	public let description: String?
	public let location: String?
	public let imageURL: URL
}
