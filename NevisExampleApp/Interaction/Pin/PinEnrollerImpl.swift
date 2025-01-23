//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `PinEnroller` protocol.
/// For more information about PIN enrollment please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/registration#pin-enroller).
///
/// Navigates to the ``CredentialScreen`` where the user can enroll the PIN authenticator.
class PinEnrollerImpl {

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

// MARK: - PinEnroller

extension PinEnrollerImpl: PinEnroller {
	func enrollPin(context: PinEnrollmentContext, handler: PinEnrollmentHandler) {
		if context.lastRecoverableError != nil {
			logger.sdk("PIN enrollment failed. Please try again.", .red)
		}
		else {
			logger.sdk("Please start PIN enrollment.")
		}

		let parameter: PinParameter = .enrollment(lastRecoverableError: context.lastRecoverableError,
		                                          handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}

	/// You can add custom PIN policy by overriding the `pinPolicy` getter.
	/// The default minimum and maximum PIN length is 6 without any furhter validation during PIN enrollment or change.
//	func pinPolicy() -> PinPolicy {
//		// custom PinPolicy implementation
//	}
}
