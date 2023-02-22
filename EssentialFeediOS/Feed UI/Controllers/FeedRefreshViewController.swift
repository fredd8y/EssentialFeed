//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 21/02/23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
	// MARK: Lifecycle

	init(presenter: FeedPresenter) {
		self.presenter = presenter
	}

	// MARK: Internal

	private(set) lazy var view = loadView()

	func display(isLoading: Bool) {
		if isLoading {
			view.beginRefreshing()
		} else {
			view.endRefreshing()
		}
	}

	@objc
	func refresh() {
		presenter.loadFeed()
	}

	// MARK: Private

	private let presenter: FeedPresenter

	private func loadView() -> UIRefreshControl {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
