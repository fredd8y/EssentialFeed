//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 04/02/23.
//

import XCTest
import EssentialFeed

// MARK: - URLSessionHTTPClient

class URLSessionHTTPClient {
	// MARK: Lifecycle

	init(session: URLSession) {
		self.session = session
	}

	// MARK: Internal

	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url, completionHandler: { _, _, error in
			if let error {
				completion(.failure(error))
			}
		}).resume()
	}

	// MARK: Private

	private let session: URLSession
}

// MARK: - URLSessionHTTPClientTests

class URLSessionHTTPClientTests: XCTestCase {
	// MARK: Internal

	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)

		let sut = URLSessionHTTPClient(session: session)

		sut.get(from: url) { _ in }

		XCTAssertEqual(task.resumeCallCount, 1)
	}

	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any error", code: 1)
		let session = URLSessionSpy()
		session.stub(url: url, error: error)

		let sut = URLSessionHTTPClient(session: session)

		let exp = expectation(description: "Wait for completion")
		
		sut.get(from: url) { result in
			switch result {
			case let .failure(receivedError as NSError):
				XCTAssertEqual(error, receivedError)
			default:
				XCTFail("Expected failure with \(error), got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1)
	}

	// MARK: Private

	// MARK: - Helpers

	private class URLSessionSpy: URLSession {
		private struct Stub {
			let task: URLSessionDataTask
			let error: Error?
		}

		// MARK: Internal

		func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
			stubs[url] = Stub(task: task, error: error)
		}

		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			guard let stub = stubs[url] else {
				fatalError("Couldn't find stub for \(url)")
			}
			completionHandler(nil, nil, stub.error)
			return stub.task
		}

		// MARK: Private

		private var stubs = [URL: Stub]()
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
