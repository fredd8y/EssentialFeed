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

	// MARK: Internal

	@IBOutlet private var view: UIRefreshControl?

	func display(_ viewModel: FeedLoadingViewModel) {
		if viewModel.isLoading {
			view?.beginRefreshing()
		} else {
			view?.endRefreshing()
		}
	}

	@IBAction func refresh() {
		delegate?.didRequestFeedRefresh()
	}

	// MARK: Private

	var delegate: FeedRefreshViewControllerDelegate?
}
