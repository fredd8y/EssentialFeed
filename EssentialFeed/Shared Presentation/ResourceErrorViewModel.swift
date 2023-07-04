//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 04/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public struct ResourceErrorViewModel {
	public let message: String?
	
	static var noError: ResourceErrorViewModel {
		return ResourceErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> ResourceErrorViewModel {
		return ResourceErrorViewModel(message: message)
	}
}
