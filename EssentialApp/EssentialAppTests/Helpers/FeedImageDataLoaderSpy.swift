//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 04/03/23.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
	private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
	
	private(set) var cancelledURls = [URL]()
	
	var loadedUrl: [URL] {
		return messages.map { $0.url }
	}
	
	private struct Task: FeedImageDataLoaderTask {
		let callback: () -> Void
		func cancel() { callback() }
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		messages.append((url, completion))
		return Task { [weak self] in
			self?.cancelledURls.append(url)
		}
	}
	
	func complete(with data: Data, at index: Int = 0) {
		messages[index].completion(.success(data))
	}
	
	func complete(with error: Error, at index: Int = 0) {
		messages[index].completion(.failure(error))
	}
}
