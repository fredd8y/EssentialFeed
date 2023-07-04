//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 04/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		
		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
	
}
