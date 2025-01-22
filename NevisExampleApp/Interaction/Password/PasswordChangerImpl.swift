//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `PasswordChanger` protocol.
/// For more information about password change please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/other-operations#change-password).
///
/// Navigates to the ``CredentialScreen`` where the user can change the Password.
class PasswordChangerImpl {

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

// MARK: - PasswordChanger

extension PasswordChangerImpl: PasswordChanger {
	func changePassword(context: PasswordChangeContext, handler: PasswordChangeHandler) {
		if context.lastRecoverableError != nil {
			logger.sdk("Password change failed. Please try again.", .red)
		}
		else {
			logger.sdk("Please start Password change.")
		}

		appCoordinator.topScreen?.enableInteraction()
		let parameter: PasswordParameter = .credentialChange(protectionStatus: context.authenticatorProtectionStatus,
		                                                     lastRecoverableError: context.lastRecoverableError,
		                                                     handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}

	func passwordPolicy() -> PasswordPolicy {
		policy
	}
}
