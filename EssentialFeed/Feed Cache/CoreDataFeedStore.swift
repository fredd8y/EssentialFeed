//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 14/02/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public init() {}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
}

private class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
}
