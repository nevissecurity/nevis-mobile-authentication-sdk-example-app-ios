//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Class for validating list of accounts.
final class AccountValidator {}

// MARK: - Actions

extension AccountValidator {

	/// Validates accounts using a context.
	///
	/// - Parameter context: The context holding the accounts to validate.
	/// - Returns: The result of the validation
	func validate(context: AccountSelectionContext) -> ValidationResult<[any Account]> {
		let supportedAuthenticators = context.authenticators.filter(\.isSupportedByHardware)
		if supportedAuthenticators.isEmpty {
			return .failure(AppError.authenticatorNotFound)
		}

		var accounts: [Username: any Account] = [:]
		supportedAuthenticators.forEach { authenticator in
			authenticator.registration.registeredAccounts.forEach { account in
				if context.isPolicyCompliant(username: account.username, aaid: authenticator.aaid) {
					accounts[account.username] = account
				}
			}
		}

		return .success(accounts.values.map { $0 })
	}
}
