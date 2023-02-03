//
//  Feedtem.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 01/02/23.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
	// MARK: Lifecycle

	public init(
		id: UUID,
		description: String?,
		location: String?,
		imageURL: URL
	) {
		self.id = id
		self.description = description
		self.location = location
		self.imageURL = imageURL
	}

	enum CodingKeys: String, CodingKey {
		case id
		case description
		case location
		case imageURL = "image"
	}
	
	// MARK: Internal

	public let id: UUID
	public let description: String?
	public let location: String?
	public let imageURL: URL
}
