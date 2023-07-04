//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 04/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
	}
}
