//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 27/02/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
	
	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
}
