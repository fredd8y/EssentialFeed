//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 13/02/23.
//

import Foundation

// MARK: - CodableFeedStore

public class CodableFeedStore: FeedStore {
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
	
	public init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	// MARK: Internal
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
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
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		do {
			let encoder = JSONEncoder()
			let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
			let encoded = try encoder.encode(cache)
			try encoded.write(to: storeURL)
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
		guard FileManager.default.fileExists(atPath: storeURL.path) else {
			return completion(nil)
		}
		
		do {
			try FileManager.default.removeItem(at: storeURL)
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	// MARK: Private
	
	private let storeURL: URL
}
