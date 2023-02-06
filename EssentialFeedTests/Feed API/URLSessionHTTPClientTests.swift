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

	func test_getFromURL_failsOnRequestError() {
		URLProtocolStub.startInterceptingRequests()
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any error", code: 1, userInfo: nil)
		URLProtocolStub.stub(url: url, error: error)

		let sut = URLSessionHTTPClient()

		let exp = expectation(description: "Wait for completion")

		sut.get(from: url) { result in
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
		URLProtocolStub.stopInterceptingRequests()
	}

	// MARK: Private

	// MARK: - Helpers

	private class URLProtocolStub: URLProtocol {
		private struct Stub {
			let error: Error?
		}

		// MARK: Internal

		static func stub(url: URL, error: Error? = nil) {
			stubs[url] = Stub(error: error)
		}

		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}

		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stubs = [:]
		}

		override class func canInit(with request: URLRequest) -> Bool {
			guard let url = request.url else { return false }
			return stubs[url] != nil
		}

		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}

		override func startLoading() {
			guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }

			if let error = stub.error {
				client?.urlProtocol(self, didFailWithError: error)

				client?.urlProtocolDidFinishLoading(self)
			}
		}

		override func stopLoading() {}

		// MARK: Private

		private static var stubs = [URL: Stub]()
	}
}
