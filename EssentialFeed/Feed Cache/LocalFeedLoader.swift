//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 09/02/23.
//

import Foundation

// MARK: - LocalFeedLoader

public final class LocalFeedLoader {
	// MARK: Lifecycle

	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	// MARK: Public

	public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
		store.deleteCacheFeed { [weak self] error in
			guard let self else { return }
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(items, with: completion)
			}
		}
	}

	// MARK: Private

	private let store: FeedStore

	private let currentDate: () -> Date

	// MARK: - Helpers

	private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
		store.insert(items, timestamp: currentDate()) { [weak self] error in
			guard self != nil else { return }
			completion(error)
		}
	}
}
