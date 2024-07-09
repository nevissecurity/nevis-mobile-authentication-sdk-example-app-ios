//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``PasswordChanger`` protocol.
///
/// Navigates to the ``CredentialScreen`` where the user can change the Password.
class PasswordChangerImpl {

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

// MARK: - PasswordChanger

extension PasswordChangerImpl: PasswordChanger {
	func changePassword(context: PasswordChangeContext, handler: PasswordChangeHandler) {
		if context.lastRecoverableError != nil {
			logger.log("Password change failed. Please try again.")
		}
		else {
			logger.log("Please start Password change.")
		}

		appCoordinator.topScreen?.enableInteraction()
		let parameter: PasswordParameter = .credentialChange(protectionStatus: context.authenticatorProtectionStatus,
		                                                     lastRecoverableError: context.lastRecoverableError,
		                                                     handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}

	/// You can add custom Password policy by overriding the `passwordPolicy` getter.
//	func passwordPolicy() -> PasswordPolicy {
//		// custom PasswordPolicy implementation
//	}
}
