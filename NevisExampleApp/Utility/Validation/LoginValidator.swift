//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Class for validating Username Password Login input data.
final class LoginValidator {}

// MARK: - Actions

extension LoginValidator {

	/// Validates Login input data.
	///
	/// - Parameters:
	///   - username: Specifies the username.
	///   - password: Specifies the password.
	/// - Returns: The result of the validation.
	func validate(_ username: String?, _ password: String?) -> ValidationResult<()> {
		if username.isEmptyOrNil, password.isEmptyOrNil {
			return .failure(AppError.loginDataNotFound)
		}

		return .success(())
	}
}
