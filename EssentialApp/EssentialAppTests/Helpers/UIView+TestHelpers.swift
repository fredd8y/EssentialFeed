//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Federico Arvat on 10/03/23.
//

import UIKit

extension UIView {
	func enforceLayoutCycle() {
		layoutIfNeeded()
		RunLoop.current.run(until: Date())
	}
}
