//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 04/02/23.
//

import EssentialFeed
import XCTest

// MARK: - URLSessionHTTPClient

class URLSessionHTTPClient {
	// MARK: Lifecycle

	init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: Internal

	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url, completionHandler: { _, _, error in
			if let error = error {
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

	override class func setUp() {
		super.setUp()

		URLProtocolStub.startInterceptingRequests()
	}

	override class func tearDown() {
		super.tearDown()

		URLProtocolStub.stopInterceptingRequests()
	}

	func test_getFromURL_performsGETRequestWithURL() {
		let url = URL(string: "http://any-url.com")!
		let exp = expectation(description: "Wait for request")

		URLProtocolStub.observeRequest { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")

			exp.fulfill()
		}

		makeSUT().get(from: url) { _ in }

		wait(for: [exp], timeout: 1)
	}

	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any error", code: 1)
		URLProtocolStub.stub(data: nil, response: nil, error: error)

		let exp = expectation(description: "Wait for completion")

		makeSUT().get(from: url) { result in
			switch result {
			case let .failure(receivedError as NSError):
				XCTAssertEqual(error.domain, receivedError.domain)
				XCTAssertEqual(error.code, receivedError.code)
			default:
				XCTFail("Expected failure with \(error), got \(result) instead")
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1)
	}

	// MARK: Private

	// MARK: - Helpers

	private class URLProtocolStub: URLProtocol {
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}

		// MARK: Internal

		static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
			stub = Stub(data: data, response: response, error: error)
		}

		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}

		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
		}

		static func observeRequest(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}

		override class func canInit(with request: URLRequest) -> Bool {
			requestObserver?(request)
			return true
		}

		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}

		override func startLoading() {
			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}
			if let response = URLProtocolStub.stub?.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			if let error = URLProtocolStub.stub?.error {
				client?.urlProtocol(self, didFailWithError: error)
			}
			client?.urlProtocolDidFinishLoading(self)
		}

		override func stopLoading() {}

		// MARK: Private

		private static var requestObserver: ((URLRequest) -> Void)?

		private static var stub: Stub?
	}

	private func makeSUT() -> URLSessionHTTPClient {
		return URLSessionHTTPClient()
	}
}
