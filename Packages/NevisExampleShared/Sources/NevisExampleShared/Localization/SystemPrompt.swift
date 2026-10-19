//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// Localized strings of the system presented user verification prompts.
public enum SystemPrompt {
	/// Biometric (Face ID, Touch ID) prompt strings.
	public enum Biometric {
		/// Reason: "Please authenticate to complete the operation."
		public static var reason: String { L10n.SystemPrompt.biometricReason }
		/// Fallback button: "Enter Passcode"
		public static var fallbackButtonTitle: String { L10n.SystemPrompt.biometricFallback }
		/// Cancel button: "Cancel"
		public static var cancelButtonTitle: String { L10n.SystemPrompt.biometricCancel }
	}

	/// Device passcode prompt strings.
	public enum DevicePasscode {
		/// Reason: "Please authenticate to complete the operation."
		public static var reason: String { L10n.SystemPrompt.devicePasscodeReason }
	}
}
