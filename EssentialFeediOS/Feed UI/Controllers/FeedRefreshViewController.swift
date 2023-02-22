//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 21/02/23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
	// MARK: Lifecycle

	init(loadFeed: @escaping () -> Void) {
		self.loadFeed = loadFeed
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
		loadFeed()
	}

	// MARK: Private

	private let loadFeed: () -> Void

	private func loadView() -> UIRefreshControl {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
