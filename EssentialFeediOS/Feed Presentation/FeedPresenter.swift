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

// MARK: - FeedPresenter

final class FeedPresenter {
	// MARK: Lifecycle

	init(feedView: FeedView, loadingView: FeedLoadingView) {
		self.feedView = feedView
		self.loadingView = loadingView
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

	func didStartLoadingFeed() {
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}

	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}

	func didFinishLoadingFeed(with error: Error) {
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}

	// MARK: Private

	private let feedView: FeedView
	private let loadingView: FeedLoadingView
}
