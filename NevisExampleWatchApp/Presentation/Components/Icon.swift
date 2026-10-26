//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

/// SF Symbols used by the app.
enum Icon {
	/// No account.
	case noAccount
	/// Generic failure.
	case error
	/// Selected list item.
	case selected
	/// Successful operation.
	case success
	/// Close button.
	case close
	/// Cool down after a failed attempt.
	case coolDown

	/// The SF Symbol name of the icon.
	var systemName: String {
		switch self {
			case .noAccount:
				"person.crop.circle.badge.questionmark"
			case .error:
				"exclamationmark.triangle.fill"
			case .selected:
				"checkmark"
			case .success:
				"checkmark.circle.fill"
			case .close:
				"xmark"
			case .coolDown:
				"hourglass"
		}
	}
}
