//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 07/02/23.
//

import Foundation

// MARK: - URLSessionHTTPClient

public class URLSessionHTTPClient: HTTPClient {
	private struct UnexpectedValuesRepresentation: Error {}

	// MARK: Lifecycle

	public init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: Public

	public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
		session.dataTask(with: url, completionHandler: { data, response, error in
			if let error = error {
				completion(.failure(error))
			} else if let data, let response = response as? HTTPURLResponse {
				completion(.success((data, response)))
			} else {
				completion(.failure(UnexpectedValuesRepresentation()))
			}
		}).resume()
	}

	// MARK: Private

	private let session: URLSession
}
