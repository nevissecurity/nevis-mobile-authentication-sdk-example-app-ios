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

	/// The biometric user verifier.
	private let biometricUserVerifier: BiometricUserVerifier

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The error handler chain.
	private let errorHandlerChain: ErrorHandlerChain

	/// The logger.
	private let logger: SDKLogger

	/// The ``MobileAuthenticationClient`` instance.
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
	///   - biometricUserVerifier: The biometric user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - logger: The logger.
	init(clientProvider: ClientProvider,
	     accountSelector: AccountSelector,
	     registrationAuthenticatorSelector: AuthenticatorSelector,
	     authenticationAuthenticatorSelector: AuthenticatorSelector,
	     pinEnroller: PinEnroller,
	     pinUserVerifier: PinUserVerifier,
	     biometricUserVerifier: BiometricUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     logger: SDKLogger) {
		self.clientProvider = clientProvider
		self.accountSelector = accountSelector
		self.registrationAuthenticatorSelector = registrationAuthenticatorSelector
		self.authenticationAuthenticatorSelector = authenticationAuthenticatorSelector
		self.pinEnroller = pinEnroller
		self.pinUserVerifier = pinUserVerifier
		self.biometricUserVerifier = biometricUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		self.logger = logger
	}

	/// :nodoc:
	deinit {
		os_log("OutOfBandOperationHandlerImpl", log: OSLog.deinit, type: .debug)
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
				self.logger.log("Decode payload succeeded.", color: .green)
				handler($0)
			}
			.onError {
				self.logger.log("Decode payload failed.", color: .red)
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
				self.logger.log("Out-of-Band operation failed.", color: .red)
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
			.biometricUserVerifier(biometricUserVerifier)
			.onSuccess {
				self.logger.log("Out-of-Band registration succeeded.", color: .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .registration))
			}
			.onError {
				self.logger.log("Out-of-Band registration failed.", color: .red)
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
			.biometricUserVerifier(biometricUserVerifier)
			.onSuccess { _ in
				self.logger.log("Out-of-Band authentication succeeded.", color: .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .authentication))
			}
			.onError {
				self.logger.log("Out-of-Band authentication failed.", color: .red)
				let operationError = OperationError(operation: .authentication, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}
}
