//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeedCache

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
	
	private var feedCacheMaxAgeInDays: Int {
		return 7
	}
	
	private func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
