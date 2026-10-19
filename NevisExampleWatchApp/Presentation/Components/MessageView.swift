//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// A full screen message with an icon, a title, a description and an optional retry button.
struct MessageView: View {
	// MARK: - Properties

	/// The icon.
	let systemImage: String
	/// The title of the view.
	let title: String
	/// The message of the view.
	let message: String
	/// Called when the retry button is tapped. The button is hidden if `nil`.
	var action: (() -> ())? = nil

	// MARK: - View

	/// The content of the view.
	var body: some View {
		ScrollView {
			ContentUnavailableView {
				Label {
					Text(title)
				} icon: {
					Image(systemName: systemImage)
				}
			} description: {
				Text(message)
			} actions: {
				if let action {
					Button(action: action) {
						Text(.retry)
					}
				}
			}
		}
	}
}
