//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// The localized strings of the package.
enum L10n {
	/// Authenticator titles.
	enum Authenticator {
		/// "PIN"
		static var pin: String { tr("authenticator_pin_title") }
		/// "Touch ID"
		static var fingerprint: String { tr("authenticator_fingerprint_title") }
		/// "Face ID"
		static var faceRecognition: String { tr("authenticator_face_recognition_title") }
		/// "Device Passcode"
		static var devicePasscode: String { tr("authenticator_device_passcode_title") }
		/// "Password"
		static var password: String { tr("authenticator_password_title") }
	}

	/// Credential prompt strings.
	enum Credential {
		/// "Enter PIN"
		static var pinPromptTitle: String { tr("credential_pin_prompt_title") }
		/// "Enter password"
		static var passwordPromptTitle: String { tr("credential_password_prompt_title") }
	}

	/// System user verification prompt strings.
	enum SystemPrompt {
		/// "Please authenticate to complete the operation."
		static var biometricReason: String { tr("biometric_prompt_reason") }
		/// "Enter Passcode"
		static var biometricFallback: String { tr("biometric_prompt_fallback_button") }
		/// "Cancel"
		static var biometricCancel: String { tr("biometric_prompt_cancel_button") }
		/// "Please authenticate to complete the operation."
		static var devicePasscodeReason: String { tr("device_passcode_prompt_reason") }
	}

	/// PIN and password protection status messages.
	enum Protection {
		/// "Your PIN/Password is blocked."
		static func lockedOut(_ kind: CredentialKind) -> String {
			tr("\(kind.rawValue)_protection_status_locked_out")
		}

		/// "You have %d try left. Please retry in %d seconds. After that your PIN/Password will be blocked."
		static func lastRetryWithCoolDown(_ kind: CredentialKind, _ remainingTries: Int, _ coolDown: Int) -> String {
			tr("\(kind.rawValue)_protection_status_last_retry_with_cool_down", remainingTries, coolDown)
		}

		/// "You have %d try left. After that your PIN/Password will be blocked."
		static func lastRetryWithoutCoolDown(_ kind: CredentialKind, _ remainingTries: Int) -> String {
			tr("\(kind.rawValue)_protection_status_last_retry_without_cool_down", remainingTries)
		}

		/// "You have %d tries left. Please retry in %d seconds."
		static func retriesWithCoolDown(_ kind: CredentialKind, _ remainingTries: Int, _ coolDown: Int) -> String {
			tr("\(kind.rawValue)_protection_status_retries_with_cool_down", remainingTries, coolDown)
		}

		/// "You have %d tries left."
		static func retriesWithoutCoolDown(_ kind: CredentialKind, _ remainingTries: Int) -> String {
			tr("\(kind.rawValue)_protection_status_retries_without_cool_down", remainingTries)
		}
	}

	/// ``WatchError`` descriptions.
	enum Error {
		/// "The iPhone app is not reachable. Open it on your iPhone."
		static var unreachable: String { tr("watch_error_unreachable") }
		/// "The iPhone did not respond in time."
		static var timeout: String { tr("watch_error_timeout") }
		/// "The operation was cancelled."
		static var cancelled: String { tr("watch_error_cancelled") }
		/// "The SDK could not be initialized on the iPhone."
		static var initializationFailed: String { tr("watch_error_initialization_failed") }
		/// "The account is not registered on the iPhone."
		static var accountNotFound: String { tr("watch_error_account_not_found") }
		/// "Another operation is already in progress on the iPhone."
		static var operationInProgress: String { tr("watch_error_operation_in_progress") }
		/// "The message could not be processed."
		static var invalidMessage: String { tr("watch_error_invalid_message") }
		/// "The app was not opened on the iPhone in time."
		static var phoneAppNotOpened: String { tr("watch_error_phone_app_not_opened") }
		/// "%@ is locked after too many failed attempts."
		static func lockedOut(_ authenticator: AuthenticatorKind) -> String {
			tr("watch_error_locked_out", authenticator.localizedTitle)
		}
	}
}

private extension L10n {
	/// Returns the localized string of the key, formatted with the arguments.
	///
	/// - Parameters:
	///   - key: The key in `Localizable.xcstrings`.
	///   - arguments: The format arguments.
	/// - Returns: The localized string.
	static func tr(_ key: String, _ arguments: any CVarArg...) -> String {
		let format = NSLocalizedString(key, bundle: .module, comment: "")
		return String(format: format, locale: .current, arguments: arguments)
	}
}
