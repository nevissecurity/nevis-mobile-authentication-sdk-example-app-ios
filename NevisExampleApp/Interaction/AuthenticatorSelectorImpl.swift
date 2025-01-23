//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// The unique name of authenticator selector implementation for Registration operation.
let RegistrationAuthenticatorSelectorName = "auth_selector_reg"

/// The unique name of authenticator selector implementation for Authentication operation.
let AuthenticationAuthenticatorSelectorName = "auth_selector_auth"

/// Default implementation of `AuthenticatorSelector` protocol.
/// For more information about authenticator selection please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/registration#authenticator-selector).
///
/// Navigates to the ``SelectAuthenticatorScreen`` where the user can select from the available authenticators.
class AuthenticatorSelectorImpl {

	/// Supported operations for authenticator selection.
	enum Operation {
		/// Registration operation.
		case registration
		/// Authentication operation.
		case authentication
	}

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The configuration loader.
	private let configurationLoader: ConfigurationLoader

	/// The current operation.
	private let operation: Operation

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	///   - configurationLoader: The configuration loader.
	///   - operation: The current operation.
	init(appCoordinator: AppCoordinator,
	     configurationLoader: ConfigurationLoader,
	     operation: Operation) {
		self.appCoordinator = appCoordinator
		self.configurationLoader = configurationLoader
		self.operation = operation
	}
}

// MARK: - AuthenticatorSelector

extension AuthenticatorSelectorImpl: AuthenticatorSelector {
	func selectAuthenticator(context: AuthenticatorSelectionContext, handler: AuthenticatorSelectionHandler) {
		guard let configuration = try? configurationLoader.load() else {
			logger.sdk("Configuration cannot be loaded during authenticator selection!", .red)
			return handler.cancel()
		}

		logger.sdk("Please select one of the received available authenticators!")

		let validator = AuthenticatorValidator()
		let validationResult = switch operation {
		case .registration: validator.validateForRegistration(context: context, allowlistedAuthenticators: configuration.authenticatorAllowlist)
		case .authentication: validator.validateForAuthentication(context: context, allowlistedAuthenticators: configuration.authenticatorAllowlist)
		}

		switch validationResult {
		case let .success(validatedAuthenticators):
			let authenticatorItems = validatedAuthenticators.map {
				AuthenticatorItem(authenticator: $0,
				                  isPolicyCompliant: context.isPolicyCompliant(authenticatorAaid: $0.aaid),
				                  isUserEnrolled: $0.isEnrolled(username: context.account.username))
			}
			let parameter: SelectAuthenticatorParameter = .select(authenticatorItems: authenticatorItems,
			                                                      handler: handler)
			if case .registration = operation {
				appCoordinator.topScreen?.enableInteraction()
			}
			appCoordinator.navigateToAuthenticatorSelection(with: parameter)
		case .failure:
			handler.cancel()
		}
	}
}
