//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``PasswordUserVerifier`` protocol.
///
/// Navigates to the ``CredentialScreen`` where the user can verify the Password.
class PasswordUserVerifierImpl {

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

// MARK: - PasswordUserVerifier

extension PasswordUserVerifierImpl: PasswordUserVerifier {
	func verifyPassword(context: PasswordUserVerificationContext, handler: PasswordUserVerificationHandler) {
		if context.lastRecoverableError != nil {
			logger.log("Password user verification failed. Please try again.")
		}
		else {
			logger.log("Please start Password user verification.")
		}

		let parameter: PasswordParameter = .verification(protectionStatus: context.authenticatorProtectionStatus,
		                                                 lastRecoverableError: context.lastRecoverableError,
		                                                 handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}
}
