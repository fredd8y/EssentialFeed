//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 03/02/23.
//

import Foundation

// MARK: - FeedItemsMapper

internal enum FeedItemsMapper {
	private static var OK_200: Int {
		return 200
	}

	internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
		guard
			response.statusCode == OK_200,
			let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items
	}

	// MARK: - Root

	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}
}
