//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 11/02/23.
//

import Foundation

// MARK: - RemoteFeedItem

internal struct RemoteFeedItem: Equatable, Decodable {
	internal let id: UUID
	internal let description: String?
	internal let location: String?
	internal let image: URL
}
