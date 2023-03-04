//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 02/03/23.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
	func test_init_doesNotLoadImageData() {
		let (_, loader) = makeSUT()
		
		XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
	}
	
	func test_loadImageData_loadsFromLoader() {
		let url = anyURL()
		let (sut, loader) = makeSUT()
		
		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URL from lader")
	}
	
	func test_loadImageData_cancelLoaderTask() {
		let url = anyURL()
		let (sut, loader) = makeSUT()
		
		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from loader")
	}
	
	func test_loadImageData_deliversDataOnLoaderSuccess() {
		let data = anyData()
		let (sut, loader) = makeSUT()
		
		expect(sut, toCompleteWith: .success(data)) {
			loader.complete(with: data)
		}
	}
	
	func test_loadImageData_deliversErrorOnLoaderError() {
		let (sut, loader) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(anyNSError())) {
			loader.complete(with: anyNSError())
		}
	}
	
	func test_loadImageData_cachesDataOnLoaderSuccess() {
		let cache = FeedImageCacheSpy()
		let url = anyURL()
		let imageData = anyData()
		let (sut, loader) = makeSUT(cache: cache)

		_ = sut.loadImageData(from: url) { _ in }

		loader.complete(with: imageData)

		XCTAssertEqual(cache.messages, [.save(data: imageData, for: url)], "Expected to cache loaded image data on success")
	}

	func test_loadImageData_doesNotCachesDataOnLoaderError() {
		let cache = FeedImageCacheSpy()
		let url = anyURL()
		let error = anyNSError()
		let (sut, loader) = makeSUT(cache: cache)

		_ = sut.loadImageData(from: url) { _ in }

		loader.complete(with: error)

		XCTAssertTrue(cache.messages.isEmpty, "Expected to not load cache on error")
	}
	
	private func makeSUT(cache: FeedImageCacheSpy = .init()) -> (sut: FeedImageDataLoaderCacheDecorator, loader: FeedImageDataLoaderSpy) {
		let loader = FeedImageDataLoaderSpy()
		let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
		trackForMemoryLeaks(loader)
		trackForMemoryLeaks(sut)
		return (sut, loader)
	}
}
