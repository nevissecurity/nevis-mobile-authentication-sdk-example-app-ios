//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2023. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of ``DevicePasscodeUserVerifier`` protocol.
class DevicePasscodeUserVerifierImpl {

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

// MARK: - DevicePasscodeUserVerifier

extension DevicePasscodeUserVerifierImpl: DevicePasscodeUserVerifier {
	func verifyDevicePasscode(context: DevicePasscodeUserVerificationContext, handler: DevicePasscodeUserVerificationHandler) {
		logger.log("Please start device passcode user verification.")

		let parameter: ConfirmationParameter = .confirmDevicePasscode(authenticator: context.authenticator.localizedTitle,
		                                                              handler: handler)
		appCoordinator.navigateToConfirmation(with: parameter)
	}
}
