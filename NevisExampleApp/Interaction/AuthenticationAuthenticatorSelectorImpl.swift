//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// The unique name of authenticator selector implementation for Authentication operation.
let AuthenticationAuthenticatorSelectorName = "auth_selector_auth"

/// Default implementation of ``AuthenticatorSelector`` protocol used for authentication.
///
/// Navigates to the ``SelectAuthenticatorScreen`` where the user can select from the available authenticators.
class AuthenticationAuthenticatorSelectorImpl {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The logger.
	private let logger: SDKLogger

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	///   - logger: The logger.
	init(appCoordinator: AppCoordinator,
	     logger: SDKLogger) {
		self.appCoordinator = appCoordinator
		self.logger = logger
	}
}

// MARK: - AuthenticatorSelector

extension AuthenticationAuthenticatorSelectorImpl: AuthenticatorSelector {
	func selectAuthenticator(context: AuthenticatorSelectionContext, handler: AuthenticatorSelectionHandler) {
		logger.log("Please select one of the received available authenticators!")
		let authenticators = context.authenticators.filter {
			guard let registration = $0.registration else {
				return false
			}

			return $0.isSupportedByHardware && registration.isRegistered(context.account.username)
		}

		let parameter: SelectAuthenticatorParameter = .select(authenticators: authenticators,
		                                                      handler: handler)
		appCoordinator.navigateToAuthenticatorSelection(with: parameter)
	}
}
