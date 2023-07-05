//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 05/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public enum ImageCommentsEndpoint {
	case get(UUID)
	
	public func url(baseURL: URL) -> URL {
		switch self {
		case let .get(id):
			return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
		}
	}
}
