//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// View model of a cell that displaying information about an available authenticator.
struct SelectAuthenticatorItemViewModel {

	// MARK: - Properties

	/// The readable title.
	let title: String

	/// Flag that tells whether the item is selectable.
	let isEnabled: Bool

	/// The readable details.
	var details: String?
}
