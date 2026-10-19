//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// Shows a trailing checkmark over the content when checked.
struct CheckmarkModifier: ViewModifier {
	// MARK: Properties

	/// Whether the checkmark is shown.
	var checked: Bool = false

	// MARK: ViewModifier

	/// Adds the checkmark to the content.
	///
	/// - Parameter content: The content to modify.
	/// - Returns: The content, with a checkmark if checked.
	func body(content: Content) -> some View {
		content.overlay(alignment: .trailing) {
			if checked {
				Image(.checkmark)
					.resizable()
					.frame(width: 20, height: 20)
					.foregroundStyle(.primary)
			}
		}
	}
}

extension View {
	/// Shows a checkmark at the trailing edge when `checked` is `true`.
	///
	/// - Parameter checked: Whether the checkmark is shown.
	/// - Returns: The view with the checkmark.
	func checkmarkStyle(checked: Bool) -> some View {
		modifier(CheckmarkModifier(checked: checked))
	}
}
