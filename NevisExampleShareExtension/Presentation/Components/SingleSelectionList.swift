//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// A titled, grouped list where one item can be selected. Sized to its rows.
struct SingleSelectionList<Item: Identifiable, Content: View>: View {
	// MARK: Properties

	/// The title shown above the list.
	let title: String
	/// The items to list.
	let items: [Item]
	/// The selected item. Updated when a row is tapped.
	@Binding var selectedItem: Item?
	/// Builds the content of a row.
	let rowContent: (Item) -> Content

	// MARK: View

	/// The content of the list.
	var body: some View {
		VStack(spacing: 8) {
			Text(title)
				.frame(maxWidth: .infinity, alignment: .leading)
				.font(.body)
				.foregroundStyle(.secondary)

			VStack(spacing: 0) {
				ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
					if index > 0 {
						Divider().padding(.leading, 16)
					}

					Button {
						selectedItem = item
					} label: {
						rowContent(item)
							.checkmarkStyle(checked: item.id == selectedItem?.id)
							.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
							.padding(.horizontal, 16)
							.padding(.vertical, 4)
							.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
					.accessibilityAddTraits(item.id == selectedItem?.id ? .isSelected : [])
				}
			}
			.cardStyle(padding: nil)
		}
	}
}
