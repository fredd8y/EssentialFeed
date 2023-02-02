//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 02/02/23.
//

import XCTest
import EssentialFeed

// MARK: - RemoteFeedLoaderTests

final class RemoteFeedLoaderTests: XCTestCase {
	// MARK: Internal

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load()

		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		client.error = NSError(domain: "Test", code: 0)
		
		var capturedError: RemoteFeedLoader.Error?
		
		sut.load() { error in
			capturedError = error
		}
		
		XCTAssertEqual(capturedError, .connectivity)
	}

	// MARK: Private

	private class HTTPClientSpy: HTTPClient {
		func get(from url: URL, completion: (Error) -> Void) {
			if let error = error {
				completion(error)
			}
			requestedURLs.append(url)
		}
		
		var requestedURLs = [URL]()
		var error: Error?
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
}
