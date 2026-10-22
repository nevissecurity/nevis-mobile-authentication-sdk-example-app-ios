//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Asks the caller for a PIN or password. Returns `nil` if the user cancels.
typealias CredentialProvider = @MainActor @Sendable (CredentialPrompt) async -> String?

/// The errors thrown by ``HeadlessAuthentication``.
enum HeadlessAuthenticationError: Error {
	/// The user cancelled the authentication.
	case cancelled
	/// The authenticator is locked out after too many failed attempts.
	///
	/// - Parameter authenticator: The locked out authenticator.
	case lockedOut(authenticator: AuthenticatorKind)
}

/// Runs an in-band authentication without the app's own screens.
///
/// The authenticator is chosen up front, the PIN or password is requested through a ``CredentialProvider``,
/// biometric and device passcode verification is presented by the system.
/// Used by the share extension and by the iPhone app on behalf of the watch.
@MainActor
enum HeadlessAuthentication {
	/// Authenticates the account with the given authenticator.
	///
	/// - Parameters:
	///   - username: The account to authenticate.
	///   - authenticator: The authenticator to use.
	///   - client: The initialized SDK client.
	///   - allowlist: The authenticators allowed by the configuration.
	///   - credentialProvider: Asks for the PIN or password.
	/// - Returns: The JWT of the authorization provider, if any.
	/// - Throws: ``HeadlessAuthenticationError`` on cancel or lockout, the SDK error otherwise.
	static func authenticate(
		_ username: String,
		using authenticator: AuthenticatorKind,
		client: MobileAuthenticationClient,
		allowlist: [AuthenticatorAaid],
		credentialProvider: @escaping CredentialProvider
	) async throws -> String? {
		try await withCheckedThrowingContinuation { continuation in
			client.operations.authentication
				.username(username)
				.authenticatorSelector(HeadlessAuthenticatorSelector(authenticator, allowlist: allowlist))
				.biometricUserVerifier(HeadlessBiometricUserVerifier())
				.devicePasscodeUserVerifier(HeadlessDevicePasscodeUserVerifier())
				.passwordUserVerifier(HeadlessPasswordUserVerifier(username: username, provider: credentialProvider))
				.pinUserVerifier(HeadlessPinUserVerifier(username: username, provider: credentialProvider))
				.onSuccess { provider in
					let jwt = (provider as? JwtAuthorizationProvider)?.jwt
					continuation.resume(returning: jwt)
				}
				.onError { error in
					continuation.resume(throwing: map(error, authenticator))
				}
				.execute()
		}
	}
}

// MARK: - Private Interface

private extension HeadlessAuthentication {
	/// Translates lockout and cancel into ``HeadlessAuthenticationError``; passes other errors through.
	///
	/// - Parameters:
	///   - error: The SDK error.
	///   - authenticator: The selected authenticator.
	/// - Returns: The error to throw.
	nonisolated static func map(_ error: AuthenticationError, _ authenticator: AuthenticatorKind) -> Error {
		if error.isLockout {
			return HeadlessAuthenticationError.lockedOut(authenticator: authenticator)
		}

		if error.isCancel {
			return HeadlessAuthenticationError.cancelled
		}

		return error
	}
}
