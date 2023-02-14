//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 14/02/23.
//

import Foundation

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
