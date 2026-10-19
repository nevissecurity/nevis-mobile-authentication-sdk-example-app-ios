//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

extension View {
	/// Lets the user dismiss the keyboard by dragging the scroll view (iOS 16+, no-op on earlier versions).
	///
	/// - Returns: The modified view.
	@ViewBuilder
	func dismissesKeyboardInteractively() -> some View {
		if #available(iOS 16.0, *) {
			scrollDismissesKeyboard(.interactively)
		} else {
			self
		}
	}
}
