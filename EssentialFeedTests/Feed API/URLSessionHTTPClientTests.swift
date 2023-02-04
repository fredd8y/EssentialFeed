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
		session.dataTask(with: url, completionHandler: { _, _, _ in }).resume()
	}

	// MARK: Private

	private let session: URLSession
}

// MARK: - URLSessionHTTPClientTests

class URLSessionHTTPClientTests: XCTestCase {
	// MARK: Internal

	func test_getFromUrl_resumesDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)

		let sut = URLSessionHTTPClient(session: session)

		sut.get(from: url)
		
		XCTAssertEqual(task.resumeCallCount, 1)
	}

	// MARK: Private

	// MARK: - Helpers

	private class URLSessionSpy: URLSession {
		// MARK: Internal

		func stub(url: URL, task: URLSessionDataTask) {
			stubs[url] = task
		}

		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			return stubs[url] ?? FakeURLSessionDataTask()
		}

		// MARK: Private

		private var stubs = [URL: URLSessionDataTask]()
	}

	private class FakeURLSessionDataTask: URLSessionDataTask {
		override func resume() {}
	}

	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCallCount = 0

		override func resume() {
			resumeCallCount += 1
		}
	}
}
