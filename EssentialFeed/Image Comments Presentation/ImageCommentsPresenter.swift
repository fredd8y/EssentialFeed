//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Federico Arvat on 04/07/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
						  tableName: "ImageComments",
						  bundle: Bundle(for: Self.self),
						  comment: "Title for the image comments view")
	}
}
