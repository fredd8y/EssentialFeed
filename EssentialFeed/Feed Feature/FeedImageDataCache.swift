//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataCache {
	typealias SaveResult = Result<Void, Error>
	
	func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
