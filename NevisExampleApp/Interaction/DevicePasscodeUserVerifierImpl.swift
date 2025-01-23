//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2023. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `DevicePasscodeUserVerifier` protocol.
/// For more information about device passcode user verification please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/registration#device-passcode-user-verifier).
///
/// Navigates to the ``ConfirmationScreen`` where the user can verify the device passcode.
class DevicePasscodeUserVerifierImpl {

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

// MARK: - DevicePasscodeUserVerifier

extension DevicePasscodeUserVerifierImpl: DevicePasscodeUserVerifier {
	func verifyDevicePasscode(context: DevicePasscodeUserVerificationContext, handler: DevicePasscodeUserVerificationHandler) {
		logger.sdk("Please start device passcode user verification.")

		let parameter: ConfirmationParameter = .confirmDevicePasscode(authenticator: context.authenticator.localizedTitle,
		                                                              handler: handler)
		appCoordinator.navigateToConfirmation(with: parameter)
	}
}
