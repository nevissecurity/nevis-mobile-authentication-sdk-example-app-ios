//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `PasswordEnroller` protocol.
/// For more information about password enrollment please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/registration#password-enroller).
///
/// Navigates to the ``CredentialScreen`` where the user can enroll the Passowrord authenticator.
class PasswordEnrollerImpl {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The password policy.
	private let policy: PasswordPolicy

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	///   - policy: The password policy.
	init(appCoordinator: AppCoordinator,
	     policy: PasswordPolicy) {
		self.appCoordinator = appCoordinator
		self.policy = policy
	}
}

// MARK: - PasswordEnroller

extension PasswordEnrollerImpl: PasswordEnroller {
	func enrollPassword(context: PasswordEnrollmentContext, handler: PasswordEnrollmentHandler) {
		if context.lastRecoverableError != nil {
			logger.sdk("Password enrollment failed. Please try again.", .red)
		}
		else {
			logger.sdk("Please start Password enrollment.")
		}

		let parameter: PasswordParameter = .enrollment(lastRecoverableError: context.lastRecoverableError,
		                                               handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}

	func passwordPolicy() -> PasswordPolicy {
		policy
	}
}
