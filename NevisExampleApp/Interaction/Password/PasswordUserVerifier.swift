//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `PasswordUserVerifier` protocol.
/// For more information about password user verification please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/authentication#password-user-verifier).
///
/// Navigates to the ``CredentialScreen`` where the user can verify the Password.
class PasswordUserVerifierImpl {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	init(appCoordinator: AppCoordinator) {
		self.appCoordinator = appCoordinator
	}
}

// MARK: - PasswordUserVerifier

extension PasswordUserVerifierImpl: PasswordUserVerifier {
	func verifyPassword(context: PasswordUserVerificationContext, handler: PasswordUserVerificationHandler) {
		if context.lastRecoverableError != nil {
			logger.sdk("Password user verification failed. Please try again.", .red)
		}
		else {
			logger.sdk("Please start Password user verification.")
		}

		let parameter: PasswordParameter = .verification(protectionStatus: context.authenticatorProtectionStatus,
		                                                 lastRecoverableError: context.lastRecoverableError,
		                                                 handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}
}
