//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 06/02/23.
//

import XCTest

extension XCTestCase {
	func trackForMemoryLeaks(
		_ instance: AnyObject,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak.", file: file, line: line)
		}
	}
}
