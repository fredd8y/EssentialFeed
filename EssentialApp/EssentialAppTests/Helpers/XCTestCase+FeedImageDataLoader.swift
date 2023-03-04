//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 04/03/23.
//

import XCTest
import EssentialFeed
import EssentialApp

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
	func expect(sut: FeedImageLoaderCacheDecorator, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
		_ = sut.loadImageData(from: anyURL()) { retrievedResult in
			switch (retrievedResult, expectedResult) {
			case let (.success(retrievedData), .success(expectedData)):
				XCTAssertEqual(retrievedData, expectedData)
			case let (.failure(retrievedError), .failure(expectedError)):
				XCTAssertEqual(retrievedError as NSError, expectedError as NSError)
			default:
				XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult) instead", file: file, line: line)
			}
		}
	}
}
