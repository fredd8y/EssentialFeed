//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 02/02/23.
//

import Foundation

// MARK: - HTTPClientResult

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

// MARK: - HTTPClient

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

// MARK: - RemoteFeedLoader

public final class RemoteFeedLoader {
	// MARK: Lifecycle

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	// MARK: Public

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public enum Result: Equatable {
		case success([FeedItem])
		case failure(Error)
	}

	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success(data, response):
				do {
					let items = try FeedItemsMapper.map(data, response: response)
					completion(.success(items))
				} catch {
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}

	// MARK: Private

	private let url: URL
	private let client: HTTPClient
}

// MARK: - FeedItemsMapper

private class FeedItemsMapper {
	static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
	}

	// MARK: - Root

	private struct Root: Decodable {
		let items: [Item]
	}

	// MARK: - Item

	private struct Item: Equatable, Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL

		var item: FeedItem {
			FeedItem(
				id: id,
				description: description,
				location: location,
				imageURL: image
			)
		}
	}
}
