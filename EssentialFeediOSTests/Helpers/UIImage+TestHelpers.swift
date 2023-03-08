//
//  UIImage+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Federico Arvat on 08/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import UIKit

extension UIImage {
	static func make(withColor color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()!
		context.setFillColor(color.cgColor)
		context.fill(rect)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return img!
	}
}
