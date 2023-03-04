//
//  FeedImageLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Federico Arvat on 04/03/23.
//

import Foundation
import EssentialFeed

public class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageCache
	
	public init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
		self.decoratee = decoratee
		self.cache = cache
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = decoratee.loadImageData(from: url) { [weak self] result in
			guard let self else { return }
			switch result {
			case let .success(data):
				self.cache.save(data, for: url) { _ in }
				completion(.success(data))
			case let .failure(error):
				completion(.failure(error))
			}
		}
		return task
	}
}
