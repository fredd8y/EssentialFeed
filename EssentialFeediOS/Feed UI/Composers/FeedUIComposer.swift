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
		let presenter = FeedPresenter(feedLoader: feedLoader)
		let refreshController = FeedRefreshViewController(presenter: presenter)
		let feedController = FeedViewController(refreshController: refreshController)
		presenter.loadingView = refreshController
		presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
		return feedController
	}

	// MARK: Private

	private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
		return { [weak controller] feed in
			controller?.tableModel = feed.map { model in
				FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
			}
		}
	}
}

// MARK: - FeedViewAdapter

private final class FeedViewAdapter: FeedView {
	// MARK: Lifecycle

	init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
		self.controller = controller
		self.imageLoader = imageLoader
	}

	// MARK: Internal

	func display(feed: [FeedImage]) {
		controller?.tableModel = feed.map { model in
			FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
		}
	}

	// MARK: Private

	private weak var controller: FeedViewController?
	private let imageLoader: FeedImageDataLoader
}
