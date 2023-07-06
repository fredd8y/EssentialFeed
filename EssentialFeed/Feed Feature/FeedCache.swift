//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 02/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedCache {
	func save(_ feed: [FeedImage]) throws
}
