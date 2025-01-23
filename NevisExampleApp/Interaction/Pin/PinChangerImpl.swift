//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `PinChanger` protocol.
/// For more information about PIN change please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/other-operations#change-pin).
///
/// Navigates to the ``CredentialScreen`` where the user can change the PIN.
class PinChangerImpl {

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

// MARK: - PinChanger

extension PinChangerImpl: PinChanger {
	func changePin(context: PinChangeContext, handler: PinChangeHandler) {
		if context.lastRecoverableError != nil {
			logger.sdk("PIN change failed. Please try again.", .red)
		}
		else {
			logger.sdk("Please start PIN change.")
		}

		appCoordinator.topScreen?.enableInteraction()
		let parameter: PinParameter = .credentialChange(protectionStatus: context.authenticatorProtectionStatus,
		                                                lastRecoverableError: context.lastRecoverableError,
		                                                handler: handler)
		appCoordinator.navigateToCredential(with: parameter)
	}

	/// You can add custom PIN policy by overriding the `pinPolicy` getter.
	/// The default minimum and maximum PIN length is 6 without any furhter validation during PIN enrollment or change.
//	func pinPolicy() -> PinPolicy {
//		// custom PinPolicy implementation
//	}
}
