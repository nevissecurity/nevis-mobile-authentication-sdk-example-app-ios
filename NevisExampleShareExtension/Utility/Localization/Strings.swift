//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// Enumeration for available localized strings.
enum L10n {
	/// Share screen related localized strings.
	enum Share {
		/// Screen title: "Nevis Example Extension"
		static let title = L10n.tr("share_title")
		/// Account list title: "Accounts"
		static let accounts = L10n.tr("share_accounts")
		/// Title when no registered accounts found: "No accounts"
		static let noAccountsTitle = L10n.tr("share_no_accounts_title")
		/// Message when no registered accounts found: "Register in the containing app first, then try again."
		static let noAccountsMessage = L10n.tr("share_no_accounts_message")
		/// Title when no registered authenticators found for the selected account: "No available authenticators"
		static let noAuthenticatorsTitle = L10n.tr("share_no_authenticators_title")
		/// Message when no registered authenticators found for the selected account: "User `username` has no authenticator usable in this extension. Register one in the containing app."
		///
		/// - Parameter username: The username of the selected account.
		/// - Returns: The localized message.
		static func noAuthenticatorsMessage(_ username: String) -> String {
			L10n.tr("share_no_authenticators_message", username)
		}
		/// Verify button: "`authenticator` Verification"
		///
		/// - Parameter authenticator: The localized title of the authenticator.
		/// - Returns: The localized message.
		static func verify(_ authenticator: String) -> String {
			L10n.tr("share_verify_button", authenticator)
		}
		/// Delete button: "Delete registration"
		static let delete = L10n.tr("share_delete_button")
		/// Done button: "Done"
		static let done = L10n.tr("share_done_button")
	}

	/// Credential card related localized strings.
	enum CredentialCard {
		/// Message for cooldown state: "Try again in `remaining` s"
		///
		/// - Parameter remaining: The remaining cooldown, in seconds.
		/// - Returns: The localized message.
		static func tryAgain(_ remaining: Int) -> String {
			L10n.tr("credential_card_try_again", remaining)
		}
		/// Submit button: "Submit"
		static let submit = L10n.tr("credential_card_submit")
		/// Cancel button: "Cancel"
		static let cancel = L10n.tr("credential_card_cancel")
	}

	/// Status related localized strings.
	enum Status {
		/// Status title related localized strings.
		enum Title {
			/// Title for ``Status/initializing`` status: "Initializing"
			static let initializing = L10n.tr("status_title_initializing")
			/// Title for ``Status/authenticating(username:)`` status: "Authenticating"
			static let authenticating = L10n.tr("status_title_authenticating")
			/// Title for ``Status/deleting(username:authenticator:)`` status: "Deleting registration"
			static let deleting = L10n.tr("status_title_deleting")
			/// Title for ``Status/authenticated(username:jwt:)`` status: "Authenticated"
			static let authenticated = L10n.tr("status_title_authenticated")
			/// Title for ``Status/ready`` status: "Initialization successful"
			static let ready = L10n.tr("status_title_ready")
			/// Title for ``Status/lockedOut(username:authenticator:)`` status: "Authenticator locked out"
			static let lockedOut = L10n.tr("status_title_locked_out")
			/// Title for ``Status/failed(cause:)`` status: "Something went wrong"
			static let failed = L10n.tr("status_title_failed")
		}

		/// Status message related localized strings.
		enum Message {
			/// Message for ``Status/initializing`` status:
			/// "Nevis Mobile Authentication client is being initialized."
			static let initializing = L10n.tr("status_message_initializing")
			/// Message for ``Status/authenticating(username:)`` status: "Verifying user `username`"
			///
			/// - Parameter username: The account being authenticated.
			/// - Returns: The localized message.
			static func authenticating(_ username: String) -> String {
				L10n.tr("status_message_authenticating", username)
			}
			/// Message for ``Status/awaitingCredential(prompt:coolDownEnd:)`` status: "User `username`"
			///
			/// - Parameter username: The account being authenticated.
			/// - Returns: The localized message.
			static func awaitingCredential(_ username: String) -> String {
				L10n.tr("status_message_awaiting_credential", username)
			}
			/// Message for ``Status/deleting(username:authenticator:)`` status:
			/// "Deleting authenticator `authenticatorTitle` for `username`"
			///
			/// - Parameters:
			///   - username: The account used for deletion.
			///   - authenticatorTitle: The localized title of the locked out authenticator to delete.
			/// - Returns: The localized message.
			static func deleting(_ username: String, _ authenticatorTitle: String) -> String {
				L10n.tr("status_message_deleting", username, authenticatorTitle)
			}
			/// Message for ``Status/authenticated(username:jwt:)`` status:
			/// "User `username` is authenticated. Received JWT: `jwt`"
			///
			/// - Parameters:
			///   - username: The authenticated account.
			///   - jwt: The received JWT.
			/// - Returns: The localized message.
			static func authenticated(_ username: String, _ jwt: String) -> String {
				L10n.tr("status_message_authenticated", username, jwt)
			}
			/// Message for ``Status/ready`` status: "Nevis Mobile Authentication client is initialized."
			static let ready = L10n.tr("status_message_ready")
			/// Message for ``Status/lockedOut(username:authenticator:)`` status: "Too many failed attempts. This registration can no longer be used."
			static let lockedOut = L10n.tr("status_message_locked_out")
		}
	}

	/// Error related localized strings.
	enum Error {
		/// Configuration error message: "Failed to load the configuration file."
		static let configuration = L10n.tr("error_configuration")
		/// Account not found error message: "Account not found."
		static let accountNotFound = L10n.tr("error_account_not_found")
		/// The client not initialized error message: "The client is not initialized."
		static let notInitialized = L10n.tr("error_not_initialized")
	}
}

extension L10n {

	/// Returns the translation for the given key from `Localizable`, formatted with the arguments.
	///
	/// - Parameters:
	///   - key: The key of the string.
	///   - args: The values for the format placeholders.
	/// - Returns: The localized string, or `key` if not found.
	private static func tr(_ key: String, _ args: CVarArg...) -> String {
		let format = Bundle.main.localizedString(forKey: key, value: nil, table: "Localizable")
		return String(format: format, locale: Locale.current, arguments: args)
	}
}
