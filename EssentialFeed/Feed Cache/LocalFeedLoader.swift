//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 09/02/23.
//

import Foundation

// MARK: - FeedCachePolicy

private final class FeedCachePolicy {
	
	private init() {}
	
	// MARK: Private

	private static let calendar = Calendar(identifier: .gregorian)

	private static var maxCacheAgeInDays: Int {
		return 7
	}

	static func validate(_ timestamp: Date, against date: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
			return false
		}
		return date < maxCacheAge
	}
}

// MARK: - LocalFeedLoader

public final class LocalFeedLoader: FeedLoader {
	// MARK: Lifecycle

	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	// MARK: Private
	
	private let store: FeedStore

	private let currentDate: () -> Date
}

public extension LocalFeedLoader {
	typealias SaveResult = Error?

	func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCacheFeed { [weak self] error in
			guard let self else { return }
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(feed, with: completion)
			}
		}
	}

	// MARK: - Helpers

	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}

public extension LocalFeedLoader {
	typealias LoadResult = LoadFeedResult

	func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self else { return }
			switch result {
			case let .failure(retrievedError):
				completion(.failure(retrievedError))
			case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
				completion(.success(feed.toModels()))
			case .found, .empty:
				completion(.success([]))
			}
		}
	}
}

public extension LocalFeedLoader {
	func validateCache() {
		store.retrieve { [weak self] result in
			guard let self else { return }
			switch result {
			case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
				self.store.deleteCacheFeed { _ in }
			case .failure:
				self.store.deleteCacheFeed { _ in }
			case .empty, .found:
				break
			}
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
