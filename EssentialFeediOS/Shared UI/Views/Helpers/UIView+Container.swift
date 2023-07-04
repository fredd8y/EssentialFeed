//
//  UIView+Container.swift
//  EssentialFeediOS
//
//  Created by Federico Arvat on 04/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import UIKit

extension UIView {
	
	public func makeContainer() -> UIView {
		let container = UIView()
		container.backgroundColor = .clear
		container.addSubview(self)
		
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: container.leadingAnchor),
			container.trailingAnchor.constraint(equalTo: trailingAnchor),
			topAnchor.constraint(equalTo: container.topAnchor),
			container.bottomAnchor.constraint(equalTo: bottomAnchor),
		])
		
		return container
	}
	
}
