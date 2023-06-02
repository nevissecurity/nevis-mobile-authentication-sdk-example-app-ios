//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Enumeration for available localized strings.
enum L10n {

	/// General, Screen related localized strings.
	enum Screen {
		/// Loading message: "Please wait..."
		static let loading = L10n.tr("screen_loading")
	}

	/// Home screen related localized strings.
	enum Home {
		/// Screen title: "Nevis Example App"
		static let title = L10n.tr("home_title")
		/// Screen description: "Registered accounts: `accountsCount`"
		///
		/// - parameter accountsCount: The number of remaining retries.
		/// - returns: The localized string.
		static func description(_ accountsCount: Any) -> String {
			L10n.tr("home_description",
			        "Localizable",
			        String(describing: accountsCount))
		}

		/// Read Qr Code button: "Read Qr Code"
		static let readQrCode = L10n.tr("home_read_qr_code_button")
		/// Authenticate button: "Authenticate"
		static let authenticate = L10n.tr("home_authenticate_button")
		/// Deregister button: "Deregister"
		static let deregister = L10n.tr("home_deregister_button")
		/// Change PIN  button: "PIN Change"
		static let changePin = L10n.tr("home_pin_change_button")
		/// Change device information button: "Change Device Information"
		static let changeDeviceInformation = L10n.tr("home_change_device_information_button")
		/// Auth cloud api registration button: "Auth Cloud Api Registration"
		static let authCloudApiRegistration = L10n.tr("home_auth_cloud_api_registration_button")
		/// Screen description: "Identity Suite only"
		static let separator = L10n.tr("home_separator")
		/// In-band registration button: "In-Band Register"
		static let inBandRegistration = L10n.tr("home_in_band_registration_button")
	}

	/// Account Selection screen related localized strings.
	enum AccountSelection {
		/// Screen title: "Select an Account"
		static let title = L10n.tr("account_selection_title")
	}

	/// Authenticator Selection screen related localized strings.
	enum AuthenticatorSelection {
		/// Screen title: "Select an Authentication Method"
		static let title = L10n.tr("authenticator_selection_title")
		/// Screen title: "Before using the authenticator, enroll it in the phone System Settings"
		static let authenticatorNotEnrolled = L10n.tr("authenticator_selection_authenticator_is_not_enrolled")
		/// Screen title: "This authentication method cannot be used with your application"
		static let authenticatorNotPolicyCompliant = L10n.tr("authenticator_selection_authenticator_is_not_policy_compliant")
	}

	/// Pin screen related localized strings.
	enum Pin {
		/// Pin enrollment related localized strings.
		enum Enrollment {
			/// Screen title: "Create PIN"
			static let title = L10n.tr("pin_enrollment_title")
			/// Screen description: "Please define a six digit PIN."
			static let description = L10n.tr("pin_enrollment_description")
		}

		/// Pin verification related localized strings.
		enum Verify {
			/// Screen title: "Verify PIN"
			static let title = L10n.tr("pin_verify_title")
			/// Screen description: "Please enter your PIN to complete the process."
			static let description = L10n.tr("pin_verify_description")
		}

		/// Pin change related localized strings.
		enum Change {
			/// Screen title: "Change PIN"
			static let title = L10n.tr("pin_change_title")
			/// Screen description: "Please define a six digit PIN."
			static let description = L10n.tr("pin_change_description")
		}

		/// Pin protection status related localized strings.
		enum ProtectionStatus {
			/// Screen description: "Please define a six digit PIN."
			static let lockedOut = L10n.tr("pin_protection_status_locked_out")

			/// Pin protection status message for last retry with cool down: "You have %@ try left.\nPlease retry in %@ seconds.\nAfter that your PIN will be blocked."
			///
			/// - parameter remainingTries: The number of remaining retries.
			/// - parameter coolDown: The cool down time.
			/// - returns: The localized string.
			static func lastRetryWithCoolDown(_ remainingTries: Any, _ coolDown: Any) -> String {
				L10n.tr("pin_protection_status_last_retry_with_cool_down",
				        "Localizable",
				        String(describing: remainingTries),
				        String(describing: coolDown))
			}

			/// Pin protection status message for last retry without cool down: "You have %@ try left.\nAfter that your PIN will be blocked."
			///
			/// - parameter remainingTries: The number of remaining retries.
			/// - returns: The localized string.
			static func lastRetryWithoutCoolDown(_ remainingTries: Any) -> String {
				L10n.tr("pin_protection_status_last_retry_without_cool_down",
				        "Localizable",
				        String(describing: remainingTries))
			}

			/// Pin protection status message for remaining retries with cool down: "You have %@ tries left.\nPlease retry in %@ seconds."
			///
			/// - parameter remainingTries: The number of remaining retries.
			/// - parameter coolDown: The cool down time.
			/// - returns: The localized string.
			static func retriesWithCoolDown(_ remainingTries: Any, _ coolDown: Any) -> String {
				L10n.tr("pin_protection_status_retries_with_cool_down",
				        "Localizable",
				        String(describing: remainingTries),
				        String(describing: coolDown))
			}

			/// Pin protection status message for remaining retries without cool down: "You have %@ tries left."
			///
			/// - parameter remainingTries: The number of remaining retries.
			/// - returns: The localized string.
			static func retriesWithoutCoolDown(_ remainingTries: Any) -> String {
				L10n.tr("pin_protection_status_retries_without_cool_down",
				        "Localizable",
				        String(describing: remainingTries))
			}
		}

		/// Pin field placeholder: "Enter PIN"
		static let pinPlaceholder = L10n.tr("pin_pin_placeholder")
		/// Pin confirm field placeholder: "Enter old PIN"
		static let oldPinPlaceholder = L10n.tr("pin_old_pin_placeholder")
		/// Done button: "Done"
		static let done = L10n.tr("pin_done_button")
		/// Confirm button: "Confirm"
		static let confirm = L10n.tr("pin_confirm_button")
		/// Cancel button: "Cancel"
		static let cancel = L10n.tr("pin_cancel_button")
		/// Missing old PIN error: "Missing old PIN."
		static let missingOldPin = L10n.tr("pin_missing_old_pin")
		/// Missing PIN error: "Missing PIN."
		static let missingPin = L10n.tr("pin_missing_pin")
	}

	/// Transaction Confirmation screen related localized strings.
	enum TrxConfirm {
		/// Screen title: "Transaction Confirmation"
		static let title = L10n.tr("transaction_confirmation_title")
		/// Confirm button: "Confirm"
		static let confirm = L10n.tr("transaction_confirmation_confirm_button")
		/// Confirm button: "Cancel"
		static let cancel = L10n.tr("transaction_confirmation_cancel_button")
	}

	/// Change Device Information screen related localized strings.
	enum ChangeDeviceInformation {
		/// Screen title: "Change Device Information"
		static let title = L10n.tr("change_device_information_title")

		/// Pin protection status message for last retry without cool down: "You have %@ try left.\nAfter that your PIN will be blocked."
		///
		/// - parameter remainingTries: The number of remaining retries.
		/// - returns: The localized string.
		static func currentName(_ currentName: Any) -> String {
			L10n.tr("change_device_information_current_name",
			        "Localizable",
			        String(describing: currentName))
		}

		/// Name field placeholder: "New name"
		static let namePlaceholder = L10n.tr("change_device_information_name_placeholder")
		/// Missing name error: "Missing name."
		static let missingName = L10n.tr("change_device_information_missing_name")
		/// Confirm button: "Confirm"
		static let confirm = L10n.tr("transaction_confirmation_confirm_button")
		/// Confirm button: "Cancel"
		static let cancel = L10n.tr("transaction_confirmation_cancel_button")
	}

	/// Auth Cloud Api Registration screen related localized strings.
	enum AuthCloudApiRegistration {
		/// Auth Cloud Api Registration input validation related localized strings.
		enum Validation {
			/// Message for missing data error: "Either the response or the appLinkUri is required."
			static let missingData = L10n.tr("auth_cloud_api_registration_missing_data")
			/// Message for wrong data error: "You cannot provide both the response and the appLinkUri."
			static let wrongData = L10n.tr("auth_cloud_api_registration_wrong_data")
		}

		/// Screen title: "Auth Cloud Registration"
		static let title = L10n.tr("auth_cloud_api_registration_title")
		/// Name field placeholder: "Enroll response"
		static let enrollResponsePlaceholder = L10n.tr("auth_cloud_api_registration_enroll_response_placeholder")
		/// Name field placeholder: "App Link Uri"
		static let appLinkUriPlaceholder = L10n.tr("auth_cloud_api_registration_app_link_uri_placeholder")
		/// Confirm button: "Confirm"
		static let confirm = L10n.tr("auth_cloud_api_registration_confirm_button")
		/// Confirm button: "Cancel"
		static let cancel = L10n.tr("auth_cloud_api_registration_cancel_button")
	}

	/// Username Password Login screen related localized strings.
	enum UsernamePasswordLogin {
		/// Screen title: "In-Band Registration"
		static let title = L10n.tr("username_password_login_title")
		/// Name field placeholder: "Enter username"
		static let usernamePlaceholder = L10n.tr("username_password_login_username_placeholder")
		/// Name field placeholder: "Enter password"
		static let passwordPlaceholder = L10n.tr("username_password_login_password_placeholder")
		/// Confirm button: "Confirm"
		static let confirm = L10n.tr("username_password_login_confirm_button")
		/// Confirm button: "Cancel"
		static let cancel = L10n.tr("username_password_login_cancel_button")
	}

	/// Result screen related localized strings.
	enum Result {
		/// Continue button: "Continue"
		static let `continue` = L10n.tr("result_continue_button")
	}

	/// Logging screen related localized strings.
	enum Logging {
		/// Screen title: "Pull to see log"
		static let title = L10n.tr("logging_title")
	}

	/// Operation related localized strings.
	enum Operation {

		/// Client initialization operation related localized strings.
		enum InitClient {
			/// Operation title: "Client initialization"
			static let title = L10n.tr("operation_init_client_title")
		}

		/// Payload decode operation related localized strings.
		enum PayloadDecode {
			/// Operation title: "Payload decode"
			static let title = L10n.tr("operation_payload_decode_title")
		}

		/// Out-of-Band operation related localized strings.
		enum OutOfBand {
			/// Operation title: "Out-of-Band operation"
			static let title = L10n.tr("operation_out_of_band_title")
		}

		/// Registration operation related localized strings.
		enum Registration {
			/// Operation title: "Registration"
			static let title = L10n.tr("operation_registration_title")
		}

		/// Authentication operation related localized strings.
		enum Authentication {
			/// Operation title: "Authentication"
			static let title = L10n.tr("operation_authentication_title")
		}

		/// Deregistration operation related localized strings.
		enum Deregistration {
			/// Operation title: "Deregistration"
			static let title = L10n.tr("operation_deregistration_title")
		}

		/// PIN change operation related localized strings.
		enum Pinchange {
			/// Operation title: "PIN change"
			static let title = L10n.tr("operation_pin_change_title")
		}

		/// Device information change operation related localized strings.
		enum DeviceInformationChange {
			/// Operation title: "Device information change"
			static let title = L10n.tr("operation_device_information_change_title")
		}

		/// Successful operation related localized strings.
		enum Success {
			/// Title: "%@ successful!"
			///
			/// - parameter operation: The current operation.
			/// - returns: The localized string.
			static func title(_ operation: Any) -> String {
				L10n.tr("operation_success_title",
				        "Localizable",
				        String(describing: operation))
			}
		}

		/// Failed operation related localized strings.
		enum Failed {
			/// Title: "%@ failed!"
			///
			/// - parameter operation: The current operation.
			/// - returns: The localized string.
			static func title(_ operation: Any) -> String {
				L10n.tr("operation_failed_title",
				        "Localizable",
				        String(describing: operation))
			}
		}
	}

	/// Authenticators related localized strings.
	enum Authenticator {
		/// PIN authenticator related localized strings.
		enum Pin {
			/// Title: "PIN"
			static let title = L10n.tr("authenticator_pin_title")
		}

		/// Face recognition authenticator related localized strings.
		enum FaceRecognition {
			/// Title: "Face ID"
			static let title = L10n.tr("authenticator_face_recognition_title")
		}

		/// Fingerprint authenticator related localized strings.
		enum Fingerprint {
			/// Title: "Touch ID"
			static let title = L10n.tr("authenticator_fingerprint_title")
		}
	}

	/// Error related localized strings.
	enum Error {
		/// App error related localized strings.
		enum App {
			/// Generic error related localized strings.
			enum Generic {
				/// Error title: "Failure"
				static let title = L10n.tr("error_generic_title")
				/// Error message: "We're sorry, it seems you encountered an unknown error. Please try again."
				static let message = L10n.tr("error_generic_message")
			}

			/// Configuration load error message: "Failed to load the configuration file."
			static let loadAppConfigurationError = L10n.tr("error_load_app_configuration_error_message")
			/// Configuration read error message: "Failed to read the login configuration."
			static let readLoginConfigurationError = L10n.tr("error_read_login_configuration_error_message")
			/// Cookies not found error message: "No cookie was provided in the username password login response."
			static let cookieNotFound = L10n.tr("error_cookie_not_found_error_message")
			/// Accounts not found error message: "There are no registered accounts."
			static let accountsNotFound = L10n.tr("error_accounts_not_found_message")
			/// Supported authenticator not found error message: "Authenticator not found."
			static let authenticatorNotFound = L10n.tr("error_authenticator_not_found_message")
			/// PIN authenticator not found error message: "Pin authenticator not found."
			static let pinAuthenticatorNotFound = L10n.tr("error_pin_authenticator_not_found_message")
			/// Device information not found error message: "No device information was found for the operation."
			static let deviceInformationNotFound = L10n.tr("error_device_information_not_found_message")
			/// Auth Cloud registration data not found error message: "Either the response or the appLinkUri is required."
			static let authCloudApiRegistrationDataNotFound = L10n.tr("error_auth_cloud_api_registration_missing_data_message")
			/// Auth Cloud registration wrong data error message: "You cannot provide both the response and the appLinkUri."
			static let authCloudApiRegistrationDataWrong = L10n.tr("error_auth_cloud_api_registration_wrong_data_message")
			/// Login data not found error message: "Please provide both username and password."
			static let loginDataNotFound = L10n.tr("error_login_missing_data_message")
			/// Login error message: "Login failed."
			static let loginFailed = L10n.tr("error_login_failed_message")
		}

		/// Qr Code scan error related localized strings.
		enum QrCodeScan {
			/// Alert title: "Error"
			static let title = L10n.tr("error_qr_scan_title")
			/// Confirm button title: "Ok"
			static let confirm = L10n.tr("error_qr_scan_confirm")

			enum Unavailable {
				/// Alert message: "Qr Code scanning is not supported using a simulator.
				/// You can start an Out-of-Band operation by opening a deep link or try out the Auth Cloud API registration."
				static let message = L10n.tr("error_qr_scan_unavailable_message")
			}

			enum Unauthorized {
				/// Alert message: "Camera access is required to scan Qr code."
				static let message = L10n.tr("error_qr_scan_unauthorized_message")
			}
		}
	}
}

extension L10n {

	/// Returns the translation for the given key.
	///
	/// - Parameters:
	///  - key: The key for a string in the table.
	///  - table: The receiver’s string table to search.
	///  - args: The arguments.
	private static func tr(_ key: String, _ table: String = "Localizable", _ args: CVarArg...) -> String {
		let format = Bundle.main.localizedString(forKey: key, value: nil, table: table)
		return String(format: format, locale: Locale.current, arguments: args)
	}
}
