//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``PinUserVerifier`` protocol.
///
/// Navigates to the ``CredentialScreen`` where the user can verify the PIN.
class PinUserVerifierImpl {

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

// MARK: - PinUserVerifier

extension PinUserVerifierImpl: PinUserVerifier {
	func verifyPin(context: PinUserVerificationContext, handler: PinUserVerificationHandler) {
		if context.lastRecoverableError != nil {
			logger.log("PIN user verification failed. Please try again.")
		}
		else {
			logger.log("Please start PIN user verification.")
		}

		let parameter: PinParameter = .verification(protectionStatus: context.authenticatorProtectionStatus,
		                                            lastRecoverableError: context.lastRecoverableError,
		                                            handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}
}
