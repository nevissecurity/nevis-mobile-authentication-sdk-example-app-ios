//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

/// A row of the account list: the username, the icons of the usable authenticators and a checkmark if selected.
struct AccountRow: View {
	// MARK: - Properties

	/// The account to show.
	let account: RegisteredAccount

	/// Whether the account is selected.
	let isSelected: Bool

	// MARK: - View

	/// The content of the row.
	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text(account.username)
					.lineLimit(1)
				HStack {
					ForEach(account.authenticators) {
						Image(systemName: $0.systemImage)
							.accessibilityLabel($0.localizedTitle)
					}
				}
				.font(.footnote)
				.foregroundStyle(.secondary)
			}
			Spacer()
			if isSelected {
				Image(systemName: Icon.selected.systemName)
					.foregroundStyle(.tint)
			}
		}
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}
