//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``PinChanger`` protocol.
///
/// Navigates to the ``PinScreen`` where the user can change the PIN.
class PinChangerImpl {

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

// MARK: - PinChanger

extension PinChangerImpl: PinChanger {
	func changePin(context: PinChangeContext, handler: PinChangeHandler) {
		if context.lastRecoverableError != nil {
			logger.log("PIN change failed. Please try again.")
		}
		else {
			logger.log("Please start PIN change.")
		}

		appCoordinator.topScreen?.enableInteraction()
		let parameter: PinParameter = .credentialChange(protectionStatus: context.authenticatorProtectionStatus,
		                                                lastRecoverableError: context.lastRecoverableError,
		                                                handler: handler)
		appCoordinator.navigateToPin(with: parameter)
	}

	/// You can add custom PIN policy by overriding the `pinPolicy` getter.
	/// The default minimum and maximum PIN length is 6 without any furhter validation during PIN enrollment or change.
//	func pinPolicy() -> PinPolicy {
//		// custom PinPolicy implementation
//	}
}
