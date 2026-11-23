//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// A rounded card with a leading icon (or spinner), a title, a message and optional extra content.
struct InfoCard<Content: View>: View {
	// MARK: - Properties

	/// The icon shown before the title.
	let icon: Icon
	/// The color of the icon or spinner.
	let tint: Color
	/// The title of the card.
	let title: String
	/// The message shown below the title.
	let message: String
	/// Whether a spinner replaces the icon.
	var spinning = false
	/// Additional content shown below the message, e.g. an action button. `EmptyView` by default.
	let extraContent: Content

	// MARK: - Initialization

	/// Creates the card.
	///
	/// - Parameters:
	///   - icon: The icon shown before the title.
	///   - tint: The color of the icon or spinner.
	///   - title: The title of the card.
	///   - message: The message shown below the title.
	///   - spinning: Whether a spinner replaces the icon.
	///   - extraContent: Builds additional content shown below the message. Empty by default.
	init(icon: Icon, tint: Color, title: String, message: String, spinning: Bool = false, @ViewBuilder extraContent: () -> Content = EmptyView.init) {
		self.icon = icon
		self.tint = tint
		self.title = title
		self.message = message
		self.spinning = spinning
		self.extraContent = extraContent()
	}

	// MARK: - View

	/// The content of the card.
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			CardHeader(icon: icon, tint: tint, title: title, spinning: spinning)

			Text(message)
				.foregroundStyle(.secondary)
				.font(.footnote)

			extraContent
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.cardStyle()
	}
}
