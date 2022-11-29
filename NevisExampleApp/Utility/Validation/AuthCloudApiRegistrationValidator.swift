//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Class for validating Auth Cloud Api Registration input data.
final class AuthCloudApiRegistrationValidator {}

// MARK: - Actions

extension AuthCloudApiRegistrationValidator {

	/// Validates Auth Cloud Api Registration input data.
	///
	/// - Parameters:
	///   - enrollResponse: Specifies the response of the Cloud HTTP API to the enroll endpoint.
	///   - appLinkUri: Specifies the value of the appLinkUri attribute in the enroll response sent by the server.
	/// - Returns: The result of the validation.
	func validate(_ enrollResponse: String?, _ appLinkUri: String?) -> ValidationResult<()> {
		if enrollResponse.isEmptyOrNil, appLinkUri.isEmptyOrNil {
			return .failure(AppError.authCloudApiRegistrationDataNotFound)
		}

		guard let enrollResponse, let appLinkUri else {
			return .success(())
		}

		if !enrollResponse.isEmpty, !appLinkUri.isEmpty {
			return .failure(AppError.authCloudApiRegistrationDataWrong)
		}

		return .success(())
	}
}
