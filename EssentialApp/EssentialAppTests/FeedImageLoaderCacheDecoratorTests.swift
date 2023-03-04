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

class FeedImageLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
	
	private func makeSUT(withResult result: FeedImageDataLoader.Result, cache: FeedImageCacheSpy = .init()) -> FeedImageLoaderCacheDecorator {
		let loader = FeedImageDataLoaderStub(result: result)
		let sut = FeedImageLoaderCacheDecorator(decoratee: loader, cache: cache)
		trackForMemoryLeaks(loader)
		trackForMemoryLeaks(sut)
		return sut
	}
	
	func test_loadImageData_deliversImageOnLoaderSuccess() {
		let data = anyData()
		let sut = makeSUT(withResult: .success(data))
		
		expect(sut: sut, toCompleteWith: .success(data))
	}
	
	func test_loadImageData_deliversErrorOnLoaderError() {
		let error = anyNSError()
		let sut = makeSUT(withResult: .failure(error))
		
		expect(sut: sut, toCompleteWith: .failure(error))
	}
	
	func test_loadImageData_cachesLoadedFeedOnLoaderSuccess() {
		let data = anyData()
		let cache = FeedImageCacheSpy()
		let sut = makeSUT(withResult: .success(data), cache: cache)
		
		_ = sut.loadImageData(from: anyURL()) { _ in }
		
		XCTAssertEqual(cache.messages, [.save(data)])
	}
	
	func test_loadImageData_doesNotCachesLoadedFeedOnLoaderError() {
		let error = anyNSError()
		let cache = FeedImageCacheSpy()
		let sut = makeSUT(withResult: .failure(error), cache: cache)
		
		_ = sut.loadImageData(from: anyURL()) { _ in }
		
		XCTAssertEqual(cache.messages, [])
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

}
