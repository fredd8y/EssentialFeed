//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 04/02/23.
//

import XCTest

// MARK: - URLSessionHTTPClient

class URLSessionHTTPClient {
	// MARK: Lifecycle

	init(session: URLSession) {
		self.session = session
	}

	// MARK: Internal

	func get(from url: URL) {
		session.dataTask(with: url, completionHandler: { _, _, _ in })
	}

	// MARK: Private

	private let session: URLSession
}

// MARK: - URLSessionHTTPClientTests

class URLSessionHTTPClientTests: XCTestCase {
	// MARK: Internal

	func test_getFromUrl_createsDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		let sut = URLSessionHTTPClient(session: session)

		sut.get(from: url)

		XCTAssertEqual(session.receivedURLs, [url])
	}

	// MARK: Private

	// MARK: - Helpers

	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()

		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			return FakeURLSessionDataTask()
		}
	}

	private class FakeURLSessionDataTask: URLSessionDataTask {}
}
