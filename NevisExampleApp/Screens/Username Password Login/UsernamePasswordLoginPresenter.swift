//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// Presenter of Username Password Login view.
final class UsernamePasswordLoginPresenter {

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

	/// The PIN enroller.
	private let passwordEnroller: PasswordEnroller

	/// The biometric user verifier.
	private let biometricUserVerifier: BiometricUserVerifier

	/// The device passcode user verifier.
	private let devicePasscodeUserVerifier: DevicePasscodeUserVerifier

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The error handler chain.
	private let errorHandlerChain: ErrorHandlerChain

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - configurationLoader: The configuration loader.
	///   - loginService: The login service.
	///   - clientProvider: The client provider.
	///   - authenticatorSelector: The authenticator selector.
	///   - pinEnroller: The PIN enroller.
	///   - passwordEnroller: The Password enroller.
	///   - biometricUserVerifier: The biometric user verifier.
	///   - devicePasscodeUserVerifier: The device passcode user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	init(configurationLoader: ConfigurationLoader,
	     loginService: LoginService,
	     clientProvider: ClientProvider,
	     authenticatorSelector: AuthenticatorSelector,
	     pinEnroller: PinEnroller,
	     passwordEnroller: PasswordEnroller,
	     biometricUserVerifier: BiometricUserVerifier,
	     devicePasscodeUserVerifier: DevicePasscodeUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain) {
		self.configurationLoader = configurationLoader
		self.loginService = loginService
		self.clientProvider = clientProvider
		self.authenticatorSelector = authenticatorSelector
		self.pinEnroller = pinEnroller
		self.passwordEnroller = passwordEnroller
		self.biometricUserVerifier = biometricUserVerifier
		self.devicePasscodeUserVerifier = devicePasscodeUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
	}

	deinit {
		logger.deinit("UsernamePasswordLoginPresenter")
	}
}

// MARK: - Public Interface

extension UsernamePasswordLoginPresenter {

	/// Starts the login.
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

private extension UsernamePasswordLoginPresenter {

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

		/// Nevis Mobile Authentication SDK supports registering authenticators in multiple servers.
		/// You can specify the base URL of the server where the registration should be made, see ``Registration/serverUrl(_:)``.
		/// If no server base URL is provided, then the base URL defined in ``Configuration/baseUrl`` will be used.
		let client = clientProvider.get()
		client?.operations.registration
			.username(username)
			.deviceInformation(DeviceInformation(name: UIDevice.extendedName))
			.authorizationProvider(CookieAuthorizationProvider(cookies))
			.authenticatorSelector(authenticatorSelector)
			.pinEnroller(pinEnroller)
			.passwordEnroller(passwordEnroller)
			.biometricUserVerifier(biometricUserVerifier)
			.devicePasscodeUserVerifier(devicePasscodeUserVerifier)
			.onSuccess {
				logger.sdk("In-Band registration succeeded.", .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .registration))
			}
			.onError {
				logger.sdk("In-Band registration failed.", .red)
				let operationError = OperationError(operation: .registration,
				                                    underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}
}
