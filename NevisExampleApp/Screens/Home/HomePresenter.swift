//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Presenter of Home view.
final class HomePresenter {

	// MARK: - Properties

	/// The view of the presenter.
	weak var view: BaseView?

	/// The configuration loader.
	private let configurationLoader: ConfigurationLoader

	/// The client provider.
	private let clientProvider: ClientProvider

	/// The PIN changer.
	private let pinChanger: PinChanger

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
	///   - configurationLoader: The configuration loader.
	///   - clientProvider: The client provider.
	///   - pinChanger: The PIN changer.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - logger: The logger.
	init(configurationLoader: ConfigurationLoader,
	     clientProvider: ClientProvider,
	     pinChanger: PinChanger,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     logger: SDKLogger) {
		self.configurationLoader = configurationLoader
		self.clientProvider = clientProvider
		self.pinChanger = pinChanger
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		self.logger = logger
	}

	/// :nodoc:
	deinit {
		os_log("HomePresenter", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Public Interface

extension HomePresenter {

	/// Initializes the client.
	///
	/// - Parameter handler: The code need to be executed on successful client initialization.
	func initClient(completion handler: @escaping () -> ()) {
		if mobileAuthenticationClient != nil {
			logger.log("Client already initialized.")
			return handler()
		}

		do {
			guard let configuration = try configurationLoader.load() else {
				errorHandlerChain.handle(error: AppError.loadAppConfigurationError)
				return
			}

			logger.log("Initializing client.")
			MobileAuthenticationClientInitializer()
				.configuration(configuration.sdkConfiguration)
				.onSuccess { client in
					self.logger.log("Client initialization succeeded.", color: .green)
					self.clientProvider.save(client: client)
					handler()
				}
				.onError {
					self.logger.log("Client initialization failed.", color: .red)
					let operationError = OperationError(operation: .initClient, underlyingError: $0)
					self.errorHandlerChain.handle(error: operationError)
				}
				.execute()
		}
		catch {
			let operationError = OperationError(operation: .initClient, underlyingError: error)
			errorHandlerChain.handle(error: operationError)
		}
	}

	/// Returns the number of registered accounts.
	///
	/// - Returns: The number of registered accounts.
	func numberOfAccounts() -> Int {
		mobileAuthenticationClient?.localData.accounts.count ?? 0
	}

	/// Starts Qr Code reading.
	func readQrCode() {
		appCoordinator.navigateToQrScanner()
	}

	/// Starts an In-Band Authentication operation.
	func authenticate() {
		let accounts = mobileAuthenticationClient?.localData.accounts ?? [any Account]()
		let parameter: SelectAccountParameter = .select(accounts: accounts,
		                                                operation: .authentication,
		                                                handler: nil,
		                                                message: nil)
		appCoordinator.navigateToAccountSelection(with: parameter)
	}

	/// Starts deregistering all accounts.
	func deregister() {
		switch configurationLoader.environment {
		case .authenticationCloud:
			guard let accounts = mobileAuthenticationClient?.localData.accounts else {
				return appCoordinator.navigateToResult(with: .success(operation: .deregistration))
			}

			view?.disableInteraction()
			let usernames = accounts.map(\.username)
			doDeregistration(for: usernames)
		case .identitySuite:
			// In the Identity Suite environment the deregistration endpoint is guarded,
			// and as such we need to provide a cookie to the deregister call.
			// Also in Identity Siute a deregistration has to be authenticated for every user,
			// so batch deregistration is not really possible.
			let accounts = mobileAuthenticationClient?.localData.accounts ?? [any Account]()
			let parameter: SelectAccountParameter = .select(accounts: accounts,
			                                                operation: .deregistration,
			                                                handler: nil,
			                                                message: nil)
			appCoordinator.navigateToAccountSelection(with: parameter)
		}
	}

	/// Starts PIN changing.
	func changePin() {
		// find PIN authenticator
		guard let authenticators = mobileAuthenticationClient?.localData.authenticators else {
			return errorHandlerChain.handle(error: AppError.pinAuthenticatorNotFound)
		}

		guard let pinAuthenticator = authenticators.filter({ $0.aaid == AuthenticatorAaid.Pin.rawValue }).first else {
			return errorHandlerChain.handle(error: AppError.pinAuthenticatorNotFound)
		}

		guard let enrollment = pinAuthenticator.userEnrollment as? SdkUserEnrollment else {
			return errorHandlerChain.handle(error: AppError.pinAuthenticatorNotFound)
		}

		// find enrolled accounts
		guard let accounts = mobileAuthenticationClient?.localData.accounts else {
			return errorHandlerChain.handle(error: AppError.accountsNotFound)
		}

		let eligibleAccounts = accounts.filter { account in
			enrollment.enrolledAccounts.contains { enrolledAccount in
				enrolledAccount.username == account.username
			}
		}

		switch eligibleAccounts.count {
		case 0:
			errorHandlerChain.handle(error: AppError.accountsNotFound)
		case 1:
			// do PIN change automatically
			doPinChange(for: eligibleAccounts.first!.username)
		default:
			// in case of multiple eligible accounts we have to show the account selection screen
			let parameter: SelectAccountParameter = .select(accounts: eligibleAccounts,
			                                                operation: .pinChange,
			                                                handler: nil,
			                                                message: nil)
			appCoordinator.navigateToAccountSelection(with: parameter)
		}
	}

	/// Starts device information change operation.
	func changeDeviceInformation() {
		let deviceInformation = mobileAuthenticationClient?.localData.deviceInformation
		guard let deviceInformation else {
			logger.log("Device information not found.", color: .red)
			return errorHandlerChain.handle(error: AppError.deviceInformationNotFound)
		}

		let parameter: ChangeDeviceInformationParameter = .change(deviceInformation: deviceInformation)
		appCoordinator.navigateToChangeDeviceInformation(with: parameter)
	}

	/// Starts Auth Cloud API registration operation.
	func authCloudApiRegister() {
		appCoordinator.navigateToAuthCloudApiRegistration()
	}

	/// Starts In-Band registration operation.
	func register() {
		appCoordinator.navigateToUsernamePasswordLogin()
	}
}

// MARK: - Private Interface

private extension HomePresenter {

	/// Deregisters all accounts.
	///
	/// - Parameters:
	///   - usernames: The list of usernames to deregister..
	func doDeregistration(for usernames: [Username]) {
		var remainingUsernames = usernames
		guard let username = remainingUsernames.popLast() else {
			logger.log("Deregistration succeeded.", color: .green)
			return appCoordinator.navigateToResult(with: .success(operation: .deregistration))
		}

		mobileAuthenticationClient?.operations.deregistration
			.username(username)
			.onSuccess {
				self.logger.log("Deregistration succeeded for user \(username)", color: .green)
				self.doDeregistration(for: remainingUsernames)
			}
			.onError {
				self.logger.log("Deregistration failed for user \(username)", color: .red)
				let operationError = OperationError(operation: .deregistration, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Starts the PIN change operation.
	///
	/// - Parameter username: The username of the account whose PIN must be changed.
	func doPinChange(for username: String) {
		view?.disableInteraction()
		mobileAuthenticationClient?.operations.pinChange
			.username(username)
			.pinChanger(pinChanger)
			.onSuccess {
				self.logger.log("PIN change succeeded.", color: .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .pinChange))
			}
			.onError {
				self.logger.log("PIN change failed.", color: .red)
				let operationError = OperationError(operation: .pinChange, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}
}
