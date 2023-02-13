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
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
