//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``BiometricUserVerifier`` protocol.
class BiometricUserVerifierImpl {

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
		self.logger = logger
		self.appCoordinator = appCoordinator
	}
}

// MARK: - BiometricUserVerifier

extension BiometricUserVerifierImpl: BiometricUserVerifier {
	func verifyBiometric(context: BiometricUserVerificationContext, handler: BiometricUserVerificationHandler) {
		logger.log("Please start biometric user verification.")

		let parameter: ConfirmationParameter = .confirmBiometric(authenticator: context.authenticator.localizedTitle,
		                                                         handler: handler)
		appCoordinator.navigateToConfirmation(with: parameter)
	}
}
