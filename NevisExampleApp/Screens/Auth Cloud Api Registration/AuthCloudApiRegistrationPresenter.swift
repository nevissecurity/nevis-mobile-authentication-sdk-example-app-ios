//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// Presenter of Auth Cloud Api Registration view.
final class AuthCloudApiRegistrationPresenter {
	// MARK: - Properties

	/// The view of the presenter.
	weak var view: BaseView?

	/// The client provider.
	private let clientProvider: ClientProvider

	/// The authenticator selector used during registration.
	private let authenticatorSelector: AuthenticatorSelector

	/// The PIN enroller.
	private let pinEnroller: PinEnroller

	/// The biometric user verifier.
	private let biometricUserVerifier: BiometricUserVerifier

	/// The device passcode user verifier.
	private let devicePasscodeUserVerifier: DevicePasscodeUserVerifier

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The error handler chain.
	private let errorHandlerChain: ErrorHandlerChain

	/// The logger.
	private let logger: SDKLogger

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - clientProvider: The client provider.
	///   - authenticatorSelector: The authenticator selector used during registration.
	///   - pinEnroller: The PIN enroller.
	///   - biometricUserVerifier: The biometric user verifier.
	///   - devicePasscodeUserVerifier: The device passcode user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - logger: The logger.
	init(clientProvider: ClientProvider,
	     authenticatorSelector: AuthenticatorSelector,
	     pinEnroller: PinEnroller,
	     biometricUserVerifier: BiometricUserVerifier,
	     devicePasscodeUserVerifier: DevicePasscodeUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     logger: SDKLogger) {
		self.clientProvider = clientProvider
		self.authenticatorSelector = authenticatorSelector
		self.pinEnroller = pinEnroller
		self.biometricUserVerifier = biometricUserVerifier
		self.devicePasscodeUserVerifier = devicePasscodeUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		self.logger = logger
	}

	/// :nodoc:
	deinit {
		os_log("AuthCloudApiRegistrationPresenter", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Public Interface

extension AuthCloudApiRegistrationPresenter {

	/// Registers based on the enrollment response or the app link URI.
	///
	/// - Parameters:
	///   - enrollResponse: The response of the Cloud HTTP API to the enroll endpoint.
	///   - appLinkUri: The value of the `appLinkUri` attribute in the enroll response sent by the server.
	func register(enrollResponse: String?, appLinkUri: String?) {
		view?.disableInteraction()
		let client = clientProvider.get()
		let deviceInformation = client?.localData.deviceInformation ?? DeviceInformation(name: UIDevice.extendedName)
		let operation = client?.operations.authCloudApiRegistration
			.deviceInformation(deviceInformation)
			.authenticatorSelector(authenticatorSelector)
			.pinEnroller(pinEnroller)
			.biometricUserVerifier(biometricUserVerifier)
			.devicePasscodeUserVerifier(devicePasscodeUserVerifier)
			.onSuccess {
				self.logger.log("Auth Cloud Api registration succeeded.", color: .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .registration))
			}
			.onError {
				self.logger.log("Auth Cloud Api registration failed.", color: .red)
				let operationError = OperationError(operation: .registration, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}

		// Emtpy string is not allowed!
		if let enrollResponse, !enrollResponse.isEmpty {
			operation?.enrollResponse(enrollResponse)
		}

		// Emtpy string is not allowed!
		if let appLinkUri, !appLinkUri.isEmpty {
			operation?.appLinkUri(appLinkUri)
		}

		operation?.execute()
	}

	/// Cancels the registration.
	func cancel() {
		appCoordinator.start()
	}
}
