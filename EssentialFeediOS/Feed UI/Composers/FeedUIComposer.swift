//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 21/02/23.
//

import EssentialFeed
import UIKit

// MARK: - FeedUIComposer

public final class FeedUIComposer {
	// MARK: Lifecycle

	private init() {}

	// MARK: Public

	public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader:
																	MainQueueDispatchDecorator(decoratee: feedLoader))
		
		let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
		
		presentationAdapter.presenter = FeedPresenter(
			feedView: FeedViewAdapter(
				controller: feedController,
				imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
			loadingView: WeakRefVirtualProxy(feedController),
			errorView: WeakRefVirtualProxy(feedController))
		
		return feedController
	}
	
	private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = delegate
		feedController.title = title
		return feedController
	}
}
