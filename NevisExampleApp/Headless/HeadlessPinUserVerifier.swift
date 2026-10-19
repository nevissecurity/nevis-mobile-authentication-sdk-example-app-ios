//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Bridges the SDK's PIN verification callback to a ``CredentialProvider``.
final class HeadlessPinUserVerifier {
	// MARK: - Properties

	/// The account being authenticated.
	private let username: String
	/// Asks for the PIN.
	private let provider: CredentialProvider

	// MARK: - Initialization

	/// Creates a verifier that asks `provider` for the PIN.
	///
	/// - Parameters:
	///   - username: The account being authenticated.
	///   - provider: Asks for the PIN. Returns `nil` if the user cancels.
	init(username: String, provider: @escaping CredentialProvider) {
		self.username = username
		self.provider = provider
	}
}

// MARK: - PinUserVerifier

extension HeadlessPinUserVerifier: PinUserVerifier {
	/// Asks the provider for the PIN and submits it, or cancels the verification if none is returned.
	///
	/// - Parameters:
	///   - context: Provides the current PIN protection status.
	///   - handler: Used to submit or cancel the PIN.
	func verifyPin(context: PinUserVerificationContext, handler: PinUserVerificationHandler) {
		Task {
			let prompt = CredentialPrompt(
				kind: .pin,
				username: username,
				protection: context.authenticatorProtectionStatus.credentialProtection
			)
			if let pin = await provider(prompt) {
				handler.verify(pin)
			} else {
				handler.cancel()
			}
		}
	}
}
