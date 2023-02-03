//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 03/02/23.
//

import Foundation

// MARK: - FeedItemsMapper

internal final class FeedItemsMapper {
	private static var OK_200: Int {
		return 200
	}
	
	internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
		guard response.statusCode == OK_200 else {
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
