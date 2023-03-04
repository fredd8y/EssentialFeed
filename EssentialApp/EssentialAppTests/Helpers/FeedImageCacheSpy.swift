//
//  FeedImageCacheSpy.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 04/03/23.
//

import Foundation
import EssentialFeed

class FeedImageCacheSpy: FeedImageDataCache {
	private(set) var messages = [Message]()
	
	enum Message: Equatable {
		case save(data: Data, for: URL)
	}
	
	func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
		messages.append(.save(data: data, for: url))
	}
}
