//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// Default implementation of ``OutOfBandOperationHandler`` protocol.
final class OutOfBandOperationHandlerImpl {
	// MARK: - Properties

	/// The client provider.
	private let clientProvider: ClientProvider

	/// The account selector.
	private let accountSelector: AccountSelector

	/// The authenticator selector used during registration.
	private let registrationAuthenticatorSelector: AuthenticatorSelector

	/// The authenticator selector used during authentication.
	private let authenticationAuthenticatorSelector: AuthenticatorSelector

	/// The PIN enroller.
	private let pinEnroller: PinEnroller

	/// The PIN user verifier.
	private let pinUserVerifier: PinUserVerifier

	/// The Password enroller.
	private let passwordEnroller: PasswordEnroller

	/// The Password user verifier.
	private let passwordUserVerifier: PasswordUserVerifier

	/// The biometric user verifier.
	private let biometricUserVerifier: BiometricUserVerifier

	/// The device passcode user verifier.
	private let devicePasscodeUserVerifier: DevicePasscodeUserVerifier

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The error handler chain.
	private let errorHandlerChain: ErrorHandlerChain

	/// The `MobileAuthenticationClient` instance.
	private var mobileAuthenticationClient: MobileAuthenticationClient? {
		clientProvider.get()
	}

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - clientProvider: The client provider.
	///   - accountSelector: The account selector.
	///   - registrationAuthenticatorSelector: The authenticator selector used during registration.
	///   - authenticationAuthenticatorSelector: The authenticator selector used during authentication.
	///   - pinEnroller: The PIN enroller.
	///   - pinUserVerifier: The PIN user verifier.
	///   - passwordEnroller: The Password enroller.
	///   - passwordUserVerifier: The Password user verifier.
	///   - biometricUserVerifier: The biometric user verifier.
	///   - devicePasscodeUserVerifier: The device passcode user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	init(clientProvider: ClientProvider,
	     accountSelector: AccountSelector,
	     registrationAuthenticatorSelector: AuthenticatorSelector,
	     authenticationAuthenticatorSelector: AuthenticatorSelector,
	     pinEnroller: PinEnroller,
	     pinUserVerifier: PinUserVerifier,
	     passwordEnroller: PasswordEnroller,
	     passwordUserVerifier: PasswordUserVerifier,
	     biometricUserVerifier: BiometricUserVerifier,
	     devicePasscodeUserVerifier: DevicePasscodeUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain) {
		self.clientProvider = clientProvider
		self.accountSelector = accountSelector
		self.registrationAuthenticatorSelector = registrationAuthenticatorSelector
		self.authenticationAuthenticatorSelector = authenticationAuthenticatorSelector
		self.pinEnroller = pinEnroller
		self.pinUserVerifier = pinUserVerifier
		self.passwordEnroller = passwordEnroller
		self.passwordUserVerifier = passwordUserVerifier
		self.biometricUserVerifier = biometricUserVerifier
		self.devicePasscodeUserVerifier = devicePasscodeUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
	}

	deinit {
		logger.deinit("OutOfBandOperationHandlerImpl")
	}
}

// MARK: - OutOfBandOperationHandler

extension OutOfBandOperationHandlerImpl: OutOfBandOperationHandler {

	func handle(payload: String) {
		decode(base64UrlEncoded: payload) {
			self.startOutOfBandOperation(with: $0)
		}
	}
}

private extension OutOfBandOperationHandlerImpl {

	/// Decodes a Base64 URL encoded string.
	///
	/// - Parameter handler: The code need to be executed on successful payload decoding.
	func decode(base64UrlEncoded: String, completion handler: @escaping (OutOfBandPayload) -> ()) {
		mobileAuthenticationClient?.operations.outOfBandPayloadDecode
			.base64UrlEncoded(base64UrlEncoded)
			.onSuccess {
				logger.sdk("Decode payload succeeded.", .green)
				handler($0)
			}
			.onError {
				logger.sdk("Decode payload failed.", .red)
				let operationError = OperationError(operation: .payloadDecode, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Starts an Out-of-Band operation with the given payload.
	///
	/// - Parameter payload: The Out-of-Band payload.
	func startOutOfBandOperation(with payload: OutOfBandPayload) {
		mobileAuthenticationClient?.operations.outOfBandOperation
			.payload(payload)
			.onRegistration {
				self.register(using: $0)
			}
			.onAuthentication {
				self.authenticate(using: $0)
			}
			.onError {
				logger.sdk("Out-of-Band operation failed.", .red)
				let operationError = OperationError(operation: .outOfBand, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Starts an Out-of-Band registration operation.
	///
	/// - Parameter registration: An ``OutOfBandRegistration`` object received from the SDK.
	func register(using registration: OutOfBandRegistration) {
		let deviceInformation = mobileAuthenticationClient?.localData.deviceInformation ?? DeviceInformation(name: UIDevice.extendedName)
		registration
			.deviceInformation(deviceInformation)
			.authenticatorSelector(registrationAuthenticatorSelector)
			.pinEnroller(pinEnroller)
			.passwordEnroller(passwordEnroller)
			.biometricUserVerifier(biometricUserVerifier)
			.devicePasscodeUserVerifier(devicePasscodeUserVerifier)
			.onSuccess {
				logger.sdk("Out-of-Band registration succeeded.", .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .registration))
			}
			.onError {
				logger.sdk("Out-of-Band registration failed.", .red)
				let operationError = OperationError(operation: .registration, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Starts an Out-of-Band authentication operation.
	///
	/// - Parameter authentication: An ``OutOfBandAuthentication`` object received from the SDK.
	func authenticate(using authentication: OutOfBandAuthentication) {
		authentication
			.accountSelector(accountSelector)
			.authenticatorSelector(authenticationAuthenticatorSelector)
			.pinUserVerifier(pinUserVerifier)
			.passwordUserVerifier(passwordUserVerifier)
			.biometricUserVerifier(biometricUserVerifier)
			.devicePasscodeUserVerifier(devicePasscodeUserVerifier)
			.onSuccess { _ in
				logger.sdk("Out-of-Band authentication succeeded.", .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .authentication))
			}
			.onError {
				logger.sdk("Out-of-Band authentication failed.", .red)
				let operationError = OperationError(operation: .authentication, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}
}
