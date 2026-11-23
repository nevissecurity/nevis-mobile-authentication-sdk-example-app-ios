//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

extension Error {
	/// Whether the error reports that the authenticator is locked out after too many failed attempts.
	var isLockout: Bool {
		if let authenticationError = self as? AuthenticationError, case let .FidoError(errorCode, _, _) = authenticationError {
			return errorCode == .userLockout
		}

		return false
	}

	/// Whether the error reports that the user cancelled the operation.
	var isCancel: Bool {
		if let authenticationError = self as? AuthenticationError, case let .FidoError(errorCode, _, _) = authenticationError {
			return errorCode == .userCanceled
		}

		return false
	}
}
