//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``PinEnroller`` protocol.
///
/// Navigates to the ``PinScreen`` where the user can enroll the PIN authenticator.
class PinEnrollerImpl {

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

// MARK: - PinEnroller

extension PinEnrollerImpl: PinEnroller {
	func enrollPin(context: PinEnrollmentContext, handler: PinEnrollmentHandler) {
		if context.lastRecoverableError != nil {
			logger.log("PIN enrollment failed. Please try again.")
		}
		else {
			logger.log("Please start PIN enrollment.")
		}

		let parameter: PinParameter = .enrollment(lastRecoverableError: context.lastRecoverableError,
		                                          handler: handler)
		appCoordinator.navigateToPin(with: parameter)
	}

	/// You can add custom PIN policy by overriding the `pinPolicy` getter
	/// The default is `PinPolicy(minLength: 6, maxLength: 6)`
	/// func pinPolicy() -> PinPolicy {
	/// 	PinPolicy(minLength: 5, maxLength: 8)
	/// }
}
