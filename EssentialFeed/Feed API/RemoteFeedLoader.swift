//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 02/02/23.
//

import Foundation

// MARK: - HTTPClient

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (Error) -> Void)
}

// MARK: - RemoteFeedLoader

public final class RemoteFeedLoader {
	// MARK: Lifecycle

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	// MARK: Public

	public func load(completion: @escaping (Error) -> Void = { _ in }) {
		client.get(from: url) { error in
			completion(.connectivity)
		}
	}

	// MARK: Private

	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
	}
}
