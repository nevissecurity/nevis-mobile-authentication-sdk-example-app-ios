//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// The icon and title row at the top of the cards.
struct CardHeader: View {
	// MARK: - Properties

	/// The icon shown before the title.
	let icon: Icon
	/// The color of the icon.
	let tint: Color
	/// The title of the card.
	let title: String
	/// Whether a spinner replaces the icon.
	var spinning = false

	// MARK: - View

	/// The content of the header.
	var body: some View {
		HStack(spacing: 8) {
			if spinning {
				ProgressView().tint(tint)
			} else {
				Image(icon)
					.foregroundStyle(tint)
					.font(.title3)
			}

			Text(title)
				.font(.headline)
		}
	}
}
