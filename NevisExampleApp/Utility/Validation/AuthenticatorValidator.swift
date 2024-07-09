//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Class for validating list of authenticators.
final class AuthenticatorValidator {}

// MARK: - Actions

extension AuthenticatorValidator {
	/// Validates authenticators for registration.
	///
	/// - Parameter context: The context holding the accounts to validate.
	/// - Parameter whitelistedAuthenticators: The array holding the whitelisted authenticators.
	/// - Returns: The result of the validation
	func validateForRegistration(context: AuthenticatorSelectionContext, whitelistedAuthenticators: [AuthenticatorAaid]) -> ValidationResult<[any Authenticator]> {
		let allowedAuthenticators = allowedAuthenticators(context: context, whitelistedAuthenticators: whitelistedAuthenticators).filter { authenticator in
			// Do not display:
			//   - policy non-compliant authenticators (this includes already registered authenticators)
			//   - not hardware supported authenticators.
			authenticator.isSupportedByHardware && context.isPolicyCompliant(authenticatorAaid: authenticator.aaid)
		}

		if allowedAuthenticators.isEmpty {
			return .failure(AppError.authenticatorNotFound)
		}

		return .success(allowedAuthenticators)
	}

	/// Validates authenticators for authentication.
	///
	/// - Parameter context: The context holding the accounts to validate.
	/// - Parameter whitelistedAuthenticators: The array holding the whitelisted authenticators.
	/// - Returns: The result of the validation
	func validateForAuthentication(context: AuthenticatorSelectionContext, whitelistedAuthenticators: [AuthenticatorAaid]) -> ValidationResult<[any Authenticator]> {
		let allowedAuthenticators = allowedAuthenticators(context: context, whitelistedAuthenticators: whitelistedAuthenticators).filter { authenticator in
			guard let registration = authenticator.registration else { return false }

			// Do not display:
			//   - policy non-registered authenticators,
			//   - not hardware supported authenticators.
			return authenticator.isSupportedByHardware && registration.isRegistered(context.account.username)
		}

		if allowedAuthenticators.isEmpty {
			return .failure(AppError.authenticatorNotFound)
		}

		return .success(allowedAuthenticators)
	}
}

// MARK: Filtering based on the authenticator whitelist

private extension AuthenticatorValidator {
	/// Filters out non-whitelisted authenticators.
	///
	/// - Parameter context: The context holding the accounts to validate.
	/// - Parameter whitelistedAuthenticators: The array holding the whitelisted authenticators.
	/// - Returns: The list of allowed authenticators.
	func allowedAuthenticators(context: AuthenticatorSelectionContext, whitelistedAuthenticators: [AuthenticatorAaid]) -> [any Authenticator] {
		context.authenticators.filter { authenticator in
			guard let authenticatorAaid = AuthenticatorAaid(rawValue: authenticator.aaid) else { return false }
			return whitelistedAuthenticators.contains(authenticatorAaid)
		}
	}
}
