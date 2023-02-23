//
//  UITableView+Dequeuing.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 23/02/23.
//

import UIKit

extension UITableView {
	func dequeueReusableCell<T: UITableViewCell>() -> T {
		let identifier = String(describing: T.self)
		return dequeueReusableCell(withIdentifier: identifier) as! T
	}
}
