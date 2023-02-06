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

	struct UnexpectedValuesRepresentation: Error {}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url, completionHandler: { _, _, error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.failure(UnexpectedValuesRepresentation()))
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
		let url = anyURL()
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
		let requestError = NSError(domain: "any error", code: 1)
		
		let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
		
		XCTAssertEqual(requestError.domain, receivedError?.domain)
		XCTAssertEqual(requestError.code, receivedError?.code)
	}
	
	func test_getFromURL_failsOnAllInvalidRepresentationCases() {
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
		XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
	}

	
	private func anyData() -> Data {
		return Data("any data".utf8)
	}
	
	private func anyNSError() -> Error {
		return NSError(domain: "any error", code: 0)
	}
	
	private func nonHTTPURLResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
	
	private func anyHTTPURLResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
		URLProtocolStub.stub(data: data, response: response, error: error)
		
		let sut = makeSUT(file: file, line: line)
		let exp = expectation(description: "Wait for completion")
		
		var receivedError: Error?
		sut.get(from: anyURL()) { result in
			switch result {
			case let .failure(error):
				receivedError = error
			default:
				XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1)
		return receivedError
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
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
