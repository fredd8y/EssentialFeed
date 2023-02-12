//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 11/02/23.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
	// MARK: Lifecycle

	public init(
		id: UUID,
		description: String?,
		location: String?,
		url: URL
	) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}

	// MARK: Public

	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
}
