//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Federico Arvat on 04/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class SharedLocalizationTests: XCTestCase {
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Shared"
		let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
		
		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
	
	private class DummyView: ResourceView {
		func display(_ viewModel: Any) {}
	}
	
}
