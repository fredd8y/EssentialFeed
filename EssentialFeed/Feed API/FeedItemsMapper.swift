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
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard
			response.statusCode == OK_200,
			let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			return .failure(.invalidData)
		}
		
		let items = root.feed
		return .success(items)
	}
	
	// MARK: - Root
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedItem] {
			return items.map { $0.item }
		}
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
