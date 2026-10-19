//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Selects the authenticator chosen by the user without showing any UI.
final class HeadlessAuthenticatorSelector {
	// MARK: - Properties

	/// The authenticator chosen by the user.
	private let authenticator: AuthenticatorKind

	/// The authenticators allowed by the configuration.
	private let allowlist: [AuthenticatorAaid]

	// MARK: - Initialization

	/// Creates a selector that selects the given authenticator.
	///
	/// - Parameters:
	///   - authenticator: The authenticator chosen by the user.
	///   - allowlist: The authenticators allowed by the configuration.
	init(_ authenticator: AuthenticatorKind, allowlist: [AuthenticatorAaid]) {
		self.authenticator = authenticator
		self.allowlist = allowlist
	}
}

// MARK: - AuthenticatorSelector

extension HeadlessAuthenticatorSelector: AuthenticatorSelector {

	/// Selects the chosen authenticator if the server offers it and it is usable for the account, otherwise cancels.
	///
	/// - Parameters:
	///   - context: Carries the authenticators offered by the server for this operation.
	///   - handler: Receives the chosen AAID.
	func selectAuthenticator(context: AuthenticatorSelectionContext, handler: AuthenticatorSelectionHandler) {
		let isOfferedAndUsable = context.authenticators.contains {
			$0.aaid == authenticator.aaid && $0.isUsable(by: context.account.username, allowlist: allowlist)
		}

		guard isOfferedAndUsable else {
			return handler.cancel()
		}

		handler.aaid(authenticator.aaid)
	}
}
