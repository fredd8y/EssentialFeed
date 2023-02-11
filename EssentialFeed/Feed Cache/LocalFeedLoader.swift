//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 09/02/23.
//

import Foundation

// MARK: - LocalFeedLoader

public final class LocalFeedLoader {
	
	public typealias SaveResult = Error?
	public typealias LoadResult = LoadFeedResult
	// MARK: Lifecycle
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	// MARK: Public
	
	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCacheFeed { [weak self] error in
			guard let self else { return }
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(feed, with: completion)
			}
		}
	}
	
	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self else { return }
			switch result {
			case let .failure(retrievedError):
				completion(.failure(retrievedError))
			case let .found(feed, timestamp) where self.validate(timestamp):
				completion(.success(feed.toModels()))
			case .found, .empty:
				completion(.success([]))
			}
		}
	}
	
	private func validate(_ timestamp: Date) -> Bool {
		let calendar = Calendar(identifier: .gregorian)
		guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else {
			return false
		}
		return currentDate() < maxCacheAge
	}

	// MARK: Private

	private let store: FeedStore

	private let currentDate: () -> Date

	// MARK: - Helpers

	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}

private extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		return map { return FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}
