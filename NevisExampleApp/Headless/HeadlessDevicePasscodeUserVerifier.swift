//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Confirms a Device Passcode prompt automatically (the system presents its own UI).
final class HeadlessDevicePasscodeUserVerifier: DevicePasscodeUserVerifier {
	// MARK: - DevicePasscodeUserVerifier

	/// Immediately confirms the Device Passcode verification without further user interaction.
	///
	/// - Parameters:
	///   - context: The system prompt needs no extra information. Unused.
	///   - handler: Signaled to proceed with the verification.
	func verifyDevicePasscode(context _: DevicePasscodeUserVerificationContext, handler: DevicePasscodeUserVerificationHandler) {
		handler.verify(using: .init(reason: SystemPrompt.DevicePasscode.reason))
	}
}
