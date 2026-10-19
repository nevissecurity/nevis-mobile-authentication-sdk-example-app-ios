//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Bridges the SDK's password verification callback to a ``CredentialProvider``.
final class HeadlessPasswordUserVerifier {
	// MARK: - Properties

	/// The account being authenticated.
	private let username: String
	/// Asks for the password.
	private let provider: CredentialProvider

	// MARK: - Initialization

	/// Creates a verifier that asks `provider` for the password.
	///
	/// - Parameters:
	///   - username: The account being authenticated.
	///   - provider: Asks for the password. Returns `nil` if the user cancels.
	init(username: String, provider: @escaping CredentialProvider) {
		self.username = username
		self.provider = provider
	}
}

// MARK: - PasswordUserVerifier

extension HeadlessPasswordUserVerifier: PasswordUserVerifier {
	/// Asks the provider for the password and submits it, or cancels the verification if none is returned.
	///
	/// - Parameters:
	///   - context: Provides the current password protection status.
	///   - handler: Used to submit or cancel the password.
	func verifyPassword(context: PasswordUserVerificationContext, handler: PasswordUserVerificationHandler) {
		Task {
			let prompt = CredentialPrompt(
				kind: .password,
				username: username,
				protection: context.authenticatorProtectionStatus.credentialProtection
			)
			if let password = await provider(prompt) {
				handler.verify(password)
			} else {
				handler.cancel()
			}
		}
	}
}
