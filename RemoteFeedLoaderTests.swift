//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 02/02/23.
//

import EssentialFeed
import XCTest

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

		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }
		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .failure(.connectivity)) {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		}
	}

	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 201, 300, 400, 500]
		let json = makeItemJSON([])
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData)) {
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .failure(.invalidData)) {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}

	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .success([])) {
			let emptyListJSON = Data(#"{"items":[]}"#.utf8)
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}

	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
		let item2 = makeItem(
			id: UUID(),
			description: "a description",
			location: "a location",
			imageURL: URL(string: "https://another-url.com")!
		)
		
		let json = makeItemJSON([item1.json, item2.json])
		expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
			client.complete(withStatusCode: 200, data: json)
		}
	}

	// MARK: Private

	private class HTTPClientSpy: HTTPClient {
		// MARK: Internal

		var requestedURLs: [URL] {
			return messages.map { $0.url }
		}

		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url, completion))
		}

		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}

		func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil
			)!
			messages[index].completion(.success(data, response))
		}

		// MARK: Private

		private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
	}

	// MARK: - Helpers

	private func makeItem(
		id: UUID,
		description: String? = nil,
		location: String? = nil,
		imageURL: URL
	) -> (model: FeedItem, json: [String: Any]) {
		let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
		let json = [
			"id": id.uuidString,
			"description": description,
			"location": location,
			"image": imageURL.absoluteString
		].compactMapValues { $0 }
		return (item, json)
	}

	private func makeItemJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}

	private func expect(
		_ sut: RemoteFeedLoader,
		toCompleteWith result: RemoteFeedLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		var capturedResults = [RemoteFeedLoader.Result]()
		sut.load { capturedResults.append($0) }
		action()
		XCTAssertEqual(capturedResults, [result], file: file, line: line)
	}
}
