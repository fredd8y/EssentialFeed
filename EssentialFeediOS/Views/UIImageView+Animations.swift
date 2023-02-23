//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 23/02/23.
//

import UIKit

extension UIImageView {
	func setImageAnimated(_ newImage: UIImage?) {
		guard newImage != nil else { return }
		image = newImage
		alpha = 0
		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}
}
