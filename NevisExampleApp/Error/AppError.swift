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
	/// No ccokie was received during Legacy Login.
	case cookieNotFound
	/// No accounts found.
	case accountsNotFound
	/// No supported authenticator found.
	case authenticatorNotFound
	/// No PIN authenticator found in the list of registered authenticators.
	case pinAuthenticatorNotFound
	/// No device information found.
	case deviceInformationNotFound
	/// No data found during Auth Cloud registration.
	case authCloudApiRegistrationDataNotFound
	/// Wrong data found during Auth Cloud registration.
	case authCloudApiRegistrationDataWrong
	/// No data found during Legacy Login.
	case legacyLoginDataNotFound
	/// Legacy Login error.
	case legacyLoginError
}

// MARK: - LocalizedError

extension AppError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .loadAppConfigurationError:
			return L10n.Error.App.loadAppConfigurationError
		case .readLoginConfigurationError:
			return L10n.Error.App.readLoginConfigurationError
		case .cookieNotFound:
			return L10n.Error.App.cookieNotFound
		case .accountsNotFound:
			return L10n.Error.App.authenticatorNotFound
		case .authenticatorNotFound:
			return L10n.Error.App.authenticatorNotFound
		case .pinAuthenticatorNotFound:
			return L10n.Error.App.pinAuthenticatorNotFound
		case .deviceInformationNotFound:
			return L10n.Error.App.deviceInformationNotFound
		case .authCloudApiRegistrationDataNotFound:
			return L10n.Error.App.authCloudApiRegistrationDataNotFound
		case .authCloudApiRegistrationDataWrong:
			return L10n.Error.App.authCloudApiRegistrationDataWrong
		case .legacyLoginDataNotFound:
			return L10n.Error.App.legacyLoginDataNotFound
		case .legacyLoginError:
			return L10n.Error.App.legacyLoginFailed
		}
	}
}
