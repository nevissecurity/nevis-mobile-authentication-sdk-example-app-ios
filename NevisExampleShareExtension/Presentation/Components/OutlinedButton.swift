//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

// MARK: - OutlinedButtonStyle

/// A full-width button style with a rounded border. Greyed out when disabled.
struct OutlinedButtonStyle: ButtonStyle {
	// MARK: Properties

	/// Whether the button is enabled.
	/// Set by `disabled(_:)` on the button or its ancestors.
	@SwiftUI.Environment(\.isEnabled) private var isEnabled

	// MARK: ButtonStyle

	/// Creates the styled button body.
	///
	/// - Parameter configuration: The label and pressed state of the button.
	/// - Returns: The styled view.
	func makeBody(configuration: Configuration) -> some View {
		let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
		configuration.label
			.frame(maxWidth: .infinity)
			.padding()
			.contentShape(Rectangle())
			.foregroundStyle(isEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
			.background(shape.fill(isEnabled ? Color.clear : Color(.systemGray5)))
			.overlay(shape.stroke(isEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.systemGray3)), lineWidth: 2))
			.opacity(configuration.isPressed ? 0.6 : 1)
	}
}

extension ButtonStyle where Self == OutlinedButtonStyle {
	/// The ``OutlinedButtonStyle``.
	static var outlined: Self {
		return .init()
	}
}

// MARK: - OutlinedButton

/// A button with an optional icon, styled with ``OutlinedButtonStyle``.
struct OutlinedButton: View {
	// MARK: Properties

	/// The button's label text.
	let title: String
	/// The icon shown before `title`.
	var icon: Icon?
	/// Called when the button is tapped.
	let action: () -> ()

	// MARK: View

	/// The content of the button.
	var body: some View {
		Button(action: action) {
			HStack {
				if let icon {
					Image(icon)
				}

				Text(title)
			}
		}
		.buttonStyle(.outlined)
		.tint(.primary)
	}
}
