//
//  FeedImageDataLoaderStub.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 04/03/23.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderStub: FeedImageDataLoader {
	let result: FeedImageDataLoader.Result
	
	init(result: FeedImageDataLoader.Result) {
		self.result = result
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = FeedImageDataLoaderTaskStub()
		
		completion(result)
		
		return task
	}
}
