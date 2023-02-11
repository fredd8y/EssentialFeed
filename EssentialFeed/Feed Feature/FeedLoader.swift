//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 01/02/23.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedImage])
	case failure(Error)
}

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
