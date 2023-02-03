//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 03/02/23.
//

import Foundation

// MARK: - HTTPClientResult

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

// MARK: - HTTPClient

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
