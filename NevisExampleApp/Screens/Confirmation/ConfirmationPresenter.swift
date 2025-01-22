//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Navigation parameter of the Confirmation view.
enum ConfirmationParameter: NavigationParameterizable {
	/// Represents biometric confirmation case.
	///
	///  - Parameter authenticator: The title of the selected authenticator.
	///  - Parameter handler: The user verification handler.
	case confirmBiometric(authenticator: String, handler: BiometricUserVerificationHandler)

	/// Represents device passcode confirmation case.
	///
	///  - Parameter authenticator: The title of the selected authenticator.
	///  - Parameter handler: The user verification handler.
	case confirmDevicePasscode(authenticator: String, handler: DevicePasscodeUserVerificationHandler)
}

/// Presenter of Confirmation view.
final class ConfirmationPresenter {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The selected authenticator.
	private var authenticator: String?

	/// The biometric user verification handler.
	private var biometricUserVerificationHandler: BiometricUserVerificationHandler?

	/// The device passcode user verification handler.
	private var devicePasscodeUserVerificationHandler: DevicePasscodeUserVerificationHandler?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	///   - parameter: The navigation parameter.
	init(appCoordinator: AppCoordinator,
	     parameter: NavigationParameterizable? = nil) {
		self.appCoordinator = appCoordinator
		setParameter(parameter as? ConfirmationParameter)
	}

	deinit {
		logger.deinit("ConfirmationPresenter")
	}
}

// MARK: - Public Interface

extension ConfirmationPresenter {

	/// Returns the actual screen title based on the operation.
	///
	/// - Returns: The actual screen title based on the operation.
	func getTitle() -> String {
		L10n.Confirmation.title(authenticator ?? String())
	}

	/// Verifies the user using the previously selected authentication method.
	func confirm() {
		biometricUserVerificationHandler?.verify()
		devicePasscodeUserVerificationHandler?.verify()
	}

	/// Cancels user verification.
	func cancel() {
		biometricUserVerificationHandler?.cancel()
		devicePasscodeUserVerificationHandler?.cancel()
	}
}

// MARK: - Private Interface

private extension ConfirmationPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: ConfirmationParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .confirmBiometric(authenticator, handler):
			self.authenticator = authenticator
			biometricUserVerificationHandler = handler
		case let .confirmDevicePasscode(authenticator, handler):
			self.authenticator = authenticator
			devicePasscodeUserVerificationHandler = handler
		}
	}
}
