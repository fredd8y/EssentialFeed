//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 21/02/23.
//

import UIKit

// MARK: - FeedRefreshViewControllerDelegate

protocol FeedRefreshViewControllerDelegate {
	func didRequestFeedRefresh()
}

// MARK: - FeedRefreshViewController

final class FeedRefreshViewController: NSObject, FeedLoadingView {
	// MARK: Lifecycle

	init(delegate: FeedRefreshViewControllerDelegate) {
		self.delegate = delegate
	}

	// MARK: Internal

	private(set) lazy var view = loadView()

	func display(_ viewModel: FeedLoadingViewModel) {
		if viewModel.isLoading {
			view.beginRefreshing()
		} else {
			view.endRefreshing()
		}
	}

	@objc
	func refresh() {
		delegate.didRequestFeedRefresh()
	}

	// MARK: Private

	private let delegate: FeedRefreshViewControllerDelegate

	private func loadView() -> UIRefreshControl {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
