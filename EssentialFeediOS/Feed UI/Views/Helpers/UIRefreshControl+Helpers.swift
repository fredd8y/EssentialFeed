//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 26/02/23.
//

import UIKit

extension UIRefreshControl {
	func update(isRefreshing: Bool) {
		isRefreshing ? beginRefreshing() : endRefreshing()
	}
}
