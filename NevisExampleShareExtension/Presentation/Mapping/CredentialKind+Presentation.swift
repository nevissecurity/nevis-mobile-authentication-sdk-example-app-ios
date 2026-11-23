//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

extension CredentialKind {
	/// The keyboard of the credential field.
	var keyboardType: UIKeyboardType {
		switch self {
			case .pin:
				.numberPad
			case .password:
				.default
		}
	}

	/// The content type of the credential field. Enables password AutoFill.
	var textContentType: UITextContentType? {
		switch self {
			case .pin:
				nil
			case .password:
				.password
		}
	}
}
