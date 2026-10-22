//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// The rounded, grouped background shared by the cards.
struct CardStyle: ViewModifier {
	// MARK: Properties

	/// The inner padding; `nil` for content that handles its own padding.
	var padding: CGFloat? = 16

	// MARK: ViewModifier

	/// Creates the styled card.
	///
	/// - Parameter content: The content to modify.
	/// - Returns: The styled content.
	func body(content: Content) -> some View {
		content
			.padding(padding ?? 0)
			.background(
				Color(.secondarySystemGroupedBackground),
				in: RoundedRectangle(cornerRadius: 8, style: .continuous)
			)
	}
}

extension View {
	/// Applies the card background and padding.
	///
	/// - Parameter padding: The inner padding; `nil` for none.
	/// - Returns: The view styled as a card.
	func cardStyle(padding: CGFloat? = 16) -> some View {
		modifier(CardStyle(padding: padding))
	}
}
