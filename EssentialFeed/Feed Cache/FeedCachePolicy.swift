//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 12/02/23.
//

import Foundation

// MARK: - FeedCachePolicy

enum FeedCachePolicy {
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
