//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 02/02/23.
//

import XCTest

// MARK: - RemoteFeedLoader

class RemoteFeedLoader {
	// MARK: Lifecycle

	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	// MARK: Internal

	let client: HTTPClient
	let url: URL

	func load() {
		client.get(from: url)
	}
}

// MARK: - HTTPClient

protocol HTTPClient {
	func get(from url: URL)
}

// MARK: - RemoteFeedLoaderTests

final class RemoteFeedLoaderTests: XCTestCase {
	// MARK: Internal

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertNil(client.requestedURL)
	}

	func test_load_requestDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load()

		XCTAssertEqual(client.requestedURL, url)
	}

	// MARK: Private

	private class HTTPClientSpy: HTTPClient {
		var requestedURL: URL?

		func get(from url: URL) {
			requestedURL = url
		}
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
}
