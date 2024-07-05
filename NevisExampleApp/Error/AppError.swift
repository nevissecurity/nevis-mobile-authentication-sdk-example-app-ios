//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// App specific errors.
enum AppError: Error {
	/// App configuration load error.
	case loadAppConfigurationError
	/// Login configuration read error.
	case readLoginConfigurationError
	/// No ccokie was received during In-Band Registration.
	case cookieNotFound
	/// No accounts found.
	case accountsNotFound
	/// No supported authenticator found.
	case authenticatorNotFound
	/// No PIN authenticator found in the list of registered authenticators.
	case pinAuthenticatorNotFound
	/// No Password authenticator found in the list of registered authenticators.
	case passwordAuthenticatorNotFound
	/// No device information found.
	case deviceInformationNotFound
	/// No data found during Auth Cloud registration.
	case authCloudApiRegistrationDataNotFound
	/// Wrong data found during Auth Cloud registration.
	case authCloudApiRegistrationDataWrong
	/// No data found during login.
	case loginDataNotFound
	/// Login error.
	case loginError
}

// MARK: - LocalizedError

extension AppError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .loadAppConfigurationError:
			L10n.Error.App.loadAppConfigurationError
		case .readLoginConfigurationError:
			L10n.Error.App.readLoginConfigurationError
		case .cookieNotFound:
			L10n.Error.App.cookieNotFound
		case .accountsNotFound:
			L10n.Error.App.accountsNotFound
		case .authenticatorNotFound:
			L10n.Error.App.authenticatorNotFound
		case .pinAuthenticatorNotFound:
			L10n.Error.App.pinAuthenticatorNotFound
		case .passwordAuthenticatorNotFound:
			L10n.Error.App.passwordAuthenticatorNotFound
		case .deviceInformationNotFound:
			L10n.Error.App.deviceInformationNotFound
		case .authCloudApiRegistrationDataNotFound:
			L10n.Error.App.authCloudApiRegistrationDataNotFound
		case .authCloudApiRegistrationDataWrong:
			L10n.Error.App.authCloudApiRegistrationDataWrong
		case .loginDataNotFound:
			L10n.Error.App.loginDataNotFound
		case .loginError:
			L10n.Error.App.loginFailed
		}
	}
}
