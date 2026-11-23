//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

extension Image {
	/// Creates an SF Symbol image from `icon`.
	///
	/// - Parameter icon: The icon to show.
	init(_ icon: Icon) {
		self.init(systemName: icon.systemName)
	}
}
