//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 02/03/23.
//

import XCTest
import EssentialFeed

protocol FeedImageCache {
	typealias SaveResult = Result<Void, Error>
	
	func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageCache
	
	init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
		self.decoratee = decoratee
		self.cache = cache
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = decoratee.loadImageData(from: url) { [weak self] result in
			guard let self else { return }
			switch result {
			case let .success(data):
				self.cache.save(data, for: url) { _ in }
				completion(.success(data))
			case let .failure(error):
				completion(.failure(error))
			}
		}
		return task
	}
}

class FeedImageLoaderCacheDecoratorTests: XCTestCase {
	
	func test_loadImageData_deliversImageOnLoaderSuccess() {
		let data = anyData()
		let cache = FeedImageCacheSpy()
		let loader = FeedImageDataLoaderStub(result: .success(data))
		let sut = FeedImageLoaderCacheDecorator(decoratee: loader, cache: cache)
		
		_ = sut.loadImageData(from: anyURL()) { result in
			switch result {
			case let .success(retrievedData):
				XCTAssertEqual(data, retrievedData)
			default:
				break
			}
		}
	}
	
	func test_loadImageData_deliversErrorOnLoaderError() {
		let error = anyNSError()
		let cache = FeedImageCacheSpy()
		let loader = FeedImageDataLoaderStub(result: .failure(error))
		let sut = FeedImageLoaderCacheDecorator(decoratee: loader, cache: cache)
		
		_ = sut.loadImageData(from: anyURL()) { result in
			switch result {
			case let .failure(retrievedError):
				XCTAssertEqual(error, retrievedError as NSError)
			default:
				break
			}
		}
	}
	
	func test_loadImageData_cachesLoadedFeedOnLoaderSuccess() {
		let data = anyData()
		let cache = FeedImageCacheSpy()
		let loader = FeedImageDataLoaderStub(result: .success(data))
		let sut = FeedImageLoaderCacheDecorator(decoratee: loader, cache: cache)
		
		_ = sut.loadImageData(from: anyURL()) { result in
			switch result {
			case let .success(retrievedData):
				XCTAssertEqual(cache.messages, [.save(retrievedData)])
			default:
				break
			}
		}
	}
	
	private class FeedImageCacheSpy: FeedImageCache {
		private(set) var messages = [Message]()
		
		enum Message: Equatable {
			case save(Data)
		}
		
		func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
			messages.append(.save(data))
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
