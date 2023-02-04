//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 04/02/23.
//

import EssentialFeed
import XCTest

// MARK: - HTTPSession

protocol HTTPSession {
	func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

// MARK: - HTTPSessionTask

protocol HTTPSessionTask {
	func resume()
}

// MARK: - URLSessionHTTPClient

class URLSessionHTTPClient {
	// MARK: Lifecycle

	init(session: HTTPSession) {
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

	private let session: HTTPSession
}

// MARK: - URLSessionHTTPClientTests

class URLSessionHTTPClientTests: XCTestCase {
	// MARK: Internal

	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = HTTPSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)

		let sut = URLSessionHTTPClient(session: session)

		sut.get(from: url) { _ in }

		XCTAssertEqual(task.resumeCallCount, 1)
	}

	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any error", code: 1)
		let session = HTTPSessionSpy()
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

	private class HTTPSessionSpy: HTTPSession {
		private struct Stub {
			let task: HTTPSessionTask
			let error: Error?
		}

		// MARK: Internal

		func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
			stubs[url] = Stub(task: task, error: error)
		}

		func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
			guard let stub = stubs[url] else {
				fatalError("Couldn't find stub for \(url)")
			}
			completionHandler(nil, nil, stub.error)
			return stub.task
		}

		// MARK: Private

		private var stubs = [URL: Stub]()
	}

	private class FakeURLSessionDataTask: HTTPSessionTask {
		func resume() {}
	}

	private class URLSessionDataTaskSpy: HTTPSessionTask {
		var resumeCallCount = 0

		func resume() {
			resumeCallCount += 1
		}
	}
}
