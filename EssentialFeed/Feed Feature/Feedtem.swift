//
//  Feedtem.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 01/02/23.
//

import Foundation

public struct FeedImage: Equatable {
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
	
	// MARK: Internal

	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
}
