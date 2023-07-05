//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 05/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedEndpointTests: XCTestCase {
	
	func test_feed_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		
		let received = FeedEndpoint.get.url(baseURL: baseURL)
		let expected = URL(string: "http://base-url.com/v1/feed")!
		
		XCTAssertEqual(received, expected)
	}
	
}
