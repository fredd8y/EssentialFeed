//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 22/02/23.
//

import EssentialFeed

// MARK: - FeedLoadingView

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

// MARK: - FeedView

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

// MARK: - FeedPresenter

final class FeedPresenter {
	// MARK: Lifecycle
	private let errorView: FeedErrorView
	
	init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedView = feedView
		self.loadingView = loadingView
		self.errorView = errorView
	}

	// MARK: Internal

	static var title: String {
		return NSLocalizedString(
			"FEED_VIEW_TITLE",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Title for the feed view"
		)
	}
	
	private var feedLoadError: String {
		return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
								 tableName: "Feed",
								 bundle: Bundle(for: FeedPresenter.self),
								 comment: "Error message displayed when we can't load the image feed from the server")
	}

	func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}

	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}

	func didFinishLoadingFeed(with error: Error) {
		errorView.display(.error(message: feedLoadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}

	// MARK: Private

	private let feedView: FeedView
	private let loadingView: FeedLoadingView
}
