//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Confirms a biometric prompt automatically (the system presents its own UI).
final class HeadlessBiometricUserVerifier: BiometricUserVerifier {
	// MARK: - BiometricUserVerifier

	/// Immediately confirms the biometric verification without further user interaction.
	///
	/// - Parameters:
	///   - context: The system prompt needs no extra information. Unused.
	///   - handler: Signaled to proceed with the verification.
	func verifyBiometric(context _: BiometricUserVerificationContext, handler: BiometricUserVerificationHandler) {
		handler.verify(
			using: .init(
				reason: SystemPrompt.Biometric.reason,
				fallbackButtonTitle: SystemPrompt.Biometric.fallbackButtonTitle,
				cancelButtonTitle: SystemPrompt.Biometric.cancelButtonTitle
			)
		)
	}
}
