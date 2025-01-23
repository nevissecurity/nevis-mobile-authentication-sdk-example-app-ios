//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `PinUserVerifier` protocol.
/// For more information about PIN user verification please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/authentication#pin-user-verifier).
///
/// Navigates to the ``CredentialScreen`` where the user can verify the PIN.
class PinUserVerifierImpl {

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

// MARK: - PinUserVerifier

extension PinUserVerifierImpl: PinUserVerifier {
	func verifyPin(context: PinUserVerificationContext, handler: PinUserVerificationHandler) {
		if context.lastRecoverableError != nil {
			logger.sdk("PIN user verification failed. Please try again.", .red)
		}
		else {
			logger.sdk("Please start PIN user verification.")
		}

		let parameter: PinParameter = .verification(protectionStatus: context.authenticatorProtectionStatus,
		                                            lastRecoverableError: context.lastRecoverableError,
		                                            handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}
}
