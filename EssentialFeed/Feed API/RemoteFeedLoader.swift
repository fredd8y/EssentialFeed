//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 02/02/23.
//

import Foundation

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
				completion(FeedItemsMapper.map(data, from: response))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}

	// MARK: Private

	private let url: URL
	private let client: HTTPClient
}

