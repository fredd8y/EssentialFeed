//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 02/02/23.
//

import Foundation

public enum HTTPClientResult {
	case success(HTTPURLResponse)
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

	public func load(completion: @escaping (Error) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .success:
				completion(.invalidData)
			case .failure:
				completion(.connectivity)
			}
		}
	}

	// MARK: Private

	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
}
