//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 02/03/23.
//

import XCTest
import EssentialFeed

class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	
	init(decoratee: FeedImageDataLoader) {
		self.decoratee = decoratee
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		return decoratee.loadImageData(from: url, completion: completion)
	}
}

class FeedImageLoaderCacheDecoratorTests: XCTestCase {
	
	func test_loadImageData_deliversImageOnLoadSuccess() {
		let data = anyData()
		let loader = FeedImageDataLoaderStub(result: .success(data))
		let sut = FeedImageLoaderCacheDecorator(decoratee: loader)
		
		_ = sut.loadImageData(from: anyURL()) { result in
			switch result {
			case let .success(retrievedData):
				XCTAssertEqual(data, retrievedData)
			default:
				break
			}
		}
		
		
	}
	
	class FeedImageDataLoaderStub: FeedImageDataLoader {
		let result: FeedImageDataLoader.Result
		
		init(result: FeedImageDataLoader.Result) {
			self.result = result
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			let task = FeedImageDataLoaderTaskStub()
			
			completion(result)
			
			return task
		}
	}
	
	class FeedImageDataLoaderTaskStub: FeedImageDataLoaderTask {
		func cancel() {}
	}
	
}
