//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``PasswordEnroller`` protocol.
///
/// Navigates to the ``CredentialScreen`` where the user can enroll the Passowrord authenticator.
class PasswordEnrollerImpl {

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

// MARK: - PasswordEnroller

extension PasswordEnrollerImpl: PasswordEnroller {
	func enrollPassword(context: PasswordEnrollmentContext, handler: PasswordEnrollmentHandler) {
		if context.lastRecoverableError != nil {
			logger.log("Password enrollment failed. Please try again.")
		}
		else {
			logger.log("Please start Password enrollment.")
		}

		let parameter: PasswordParameter = .enrollment(lastRecoverableError: context.lastRecoverableError,
		                                               handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}

	/// You can add custom Password policy by overriding the `passwordPolicy` getter.
//	func passwordPolicy() -> PasswordPolicy {
//		// custom PasswordPolicy implementation
//	}
}
