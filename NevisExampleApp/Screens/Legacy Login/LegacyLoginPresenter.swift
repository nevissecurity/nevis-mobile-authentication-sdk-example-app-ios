//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// Presenter of Legacy Login view.
final class LegacyLoginPresenter {

	// MARK: - Properties

	/// The view of the presenter.
	weak var view: BaseView?

	/// The configuration loader.
	private let configurationLoader: ConfigurationLoader

	/// The login service.
	private let loginService: LoginService

	/// The client provider.
	private let clientProvider: ClientProvider

	/// The authenticator selector.
	private let authenticatorSelector: AuthenticatorSelector

	/// The PIN enroller.
	private let pinEnroller: PinEnroller

	/// The biometric user verifier.
	private let biometricUserVerifier: BiometricUserVerifier

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
	///   - configurationLoader: The configuration loader.
	///   - loginService: The login service.
	///   - clientProvider: The client provider.
	///   - authenticatorSelector: The authenticator selector.
	///   - pinEnroller: The PIN enroller.
	///   - biometricUserVerifier: The biometric user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - logger: The logger.
	init(configurationLoader: ConfigurationLoader,
	     loginService: LoginService,
	     clientProvider: ClientProvider,
	     authenticatorSelector: AuthenticatorSelector,
	     pinEnroller: PinEnroller,
	     biometricUserVerifier: BiometricUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     logger: SDKLogger) {
		self.configurationLoader = configurationLoader
		self.loginService = loginService
		self.clientProvider = clientProvider
		self.authenticatorSelector = authenticatorSelector
		self.pinEnroller = pinEnroller
		self.biometricUserVerifier = biometricUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		self.logger = logger
	}

	/// :nodoc:
	deinit {
		os_log("LegacyLoginPresenter", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Public Interface

extension LegacyLoginPresenter {

	/// Starts the legacy login.
	///
	/// - Parameters:
	///   - username: The username.
	///   - password: The password.
	func login(username: String, password: String) {
		do {
			guard let configuration = try configurationLoader.load() else {
				errorHandlerChain.handle(error: AppError.loadAppConfigurationError)
				return
			}

			guard let url = URL(string: configuration.loginConfiguration.loginRequestURL) else {
				let operationError = OperationError(operation: .registration,
				                                    underlyingError: AppError.readLoginConfigurationError)
				return errorHandlerChain.handle(error: operationError)
			}

			view?.disableInteraction()
			let request = LoginRequest(url: url, username: username, password: password)
			loginService.send(request: request) { result in
				switch result {
				case let .success(response):
					self.register(username: response.extId, cookies: response.cookies)
				case let .failure(error):
					let operationError = OperationError(operation: .registration,
					                                    underlyingError: error)
					self.errorHandlerChain.handle(error: operationError)
				}
			}
		}
		catch {
			let operationError = OperationError(operation: .registration,
			                                    underlyingError: error)
			errorHandlerChain.handle(error: operationError)
		}
	}

	/// Cancels the login.
	func cancel() {
		appCoordinator.start()
	}
}

// MARK: - Private Interface

private extension LegacyLoginPresenter {

	/// Starts the In-Band registration operation.
	///
	/// - Parameters:
	///   - username: The username.
	///   - cookies: The cookies used for authorization.
	func register(username: String, cookies: [HTTPCookie]?) {
		guard let cookies, !cookies.isEmpty else {
			let operationError = OperationError(operation: .registration,
			                                    underlyingError: AppError.cookieNotFound)
			return errorHandlerChain.handle(error: operationError)
		}

		let client = clientProvider.get()
		client?.operations.registration
			.username(username)
			.deviceInformation(DeviceInformation(name: UIDevice.extendedName))
			.authorizationProvider(CookieAuthorizationProvider(cookies))
			.authenticatorSelector(authenticatorSelector)
			.pinEnroller(pinEnroller)
			.biometricUserVerifier(biometricUserVerifier)
			.onSuccess {
				self.appCoordinator.navigateToResult(with: .success(operation: .registration))
			}
			.onError {
				let operationError = OperationError(operation: .registration,
				                                    underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}
}
