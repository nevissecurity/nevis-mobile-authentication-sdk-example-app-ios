//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `BiometricUserVerifier` protocol.
/// For more information about biometric user verification please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/registration#biometric-user-verifier).
///
/// Navigates to the ``ConfirmationScreen`` where the user can verify the biometrics.
class BiometricUserVerifierImpl {

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

// MARK: - BiometricUserVerifier

extension BiometricUserVerifierImpl: BiometricUserVerifier {
	func verifyBiometric(context: BiometricUserVerificationContext, handler: BiometricUserVerificationHandler) {
		logger.sdk("Please start biometric user verification.")

		let parameter: ConfirmationParameter = .confirmBiometric(authenticator: context.authenticator.localizedTitle,
		                                                         handler: handler)
		appCoordinator.navigateToConfirmation(with: parameter)
	}
}
