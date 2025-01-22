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

	/// The Password changer.
	private let passwordChanger: PasswordChanger

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
	///   - configurationLoader: The configuration loader.
	///   - clientProvider: The client provider.
	///   - pinChanger: The PIN changer.
	///   - passwordChanger: The Password changer.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	init(configurationLoader: ConfigurationLoader,
	     clientProvider: ClientProvider,
	     pinChanger: PinChanger,
	     passwordChanger: PasswordChanger,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain) {
		self.configurationLoader = configurationLoader
		self.clientProvider = clientProvider
		self.pinChanger = pinChanger
		self.passwordChanger = passwordChanger
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
	}

	deinit {
		logger.deinit("HomePresenter")
	}
}

// MARK: - Public Interface

extension HomePresenter {

	/// Initializes the client.
	///
	/// - Parameter handler: The code need to be executed on successful client initialization.
	func initClient(completion handler: @escaping () -> ()) {
		if mobileAuthenticationClient != nil {
			logger.sdk("Client already initialized.")
			return handler()
		}

		do {
			guard let configuration = try configurationLoader.load() else {
				errorHandlerChain.handle(error: AppError.loadAppConfigurationError)
				return
			}

			logger.sdk("Initializing client.")
			MobileAuthenticationClientInitializer()
				.configuration(configuration.sdkConfiguration)
				.onSuccess { client in
					logger.sdk("Client initialization succeeded.", .green)
					self.clientProvider.save(client: client)
					handler()
				}
				.onError {
					logger.sdk("Client initialization failed.", .red)
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
		guard let accounts = mobileAuthenticationClient?.localData.accounts, !accounts.isEmpty else {
			logger.sdk("Accounts not found.", .red)
			let operationError = OperationError(operation: .authentication,
			                                    underlyingError: AppError.accountsNotFound)
			return errorHandlerChain.handle(error: operationError)
		}

		let parameter: SelectAccountParameter = .select(accounts: accounts,
		                                                operation: .authentication,
		                                                handler: nil,
		                                                message: nil)
		appCoordinator.navigateToAccountSelection(with: parameter)
	}

	/// Starts deregistering all accounts.
	func deregister() {
		guard let accounts = mobileAuthenticationClient?.localData.accounts, !accounts.isEmpty else {
			let operationError = OperationError(operation: .deregistration,
			                                    underlyingError: AppError.accountsNotFound)
			return errorHandlerChain.handle(error: operationError)
		}

		switch configurationLoader.environment {
		case .authenticationCloud:
			view?.disableInteraction()
			let usernames = accounts.map(\.username)
			doDeregistration(for: usernames)
		case .identitySuite:
			// In the Identity Suite environment the deregistration endpoint is guarded,
			// and as such we need to provide a cookie to the deregister call.
			let parameter: SelectAccountParameter = .select(accounts: accounts,
			                                                operation: .deregistration,
			                                                handler: nil,
			                                                message: nil)
			appCoordinator.navigateToAccountSelection(with: parameter)
		}
	}

	/// Starts Credential changing.
	func changeCredential(_ authenticatorType: AuthenticatorAaid) {
		let operation: Operation = authenticatorType == .Pin ? .pinChange : .passwordChange
		let authenticatorNotFoundError: AppError = authenticatorType == .Pin ? .pinAuthenticatorNotFound : .passwordAuthenticatorNotFound

		// find enrolled accounts
		guard let accounts = mobileAuthenticationClient?.localData.accounts, !accounts.isEmpty else {
			let operationError = OperationError(operation: operation,
			                                    underlyingError: AppError.accountsNotFound)
			return errorHandlerChain.handle(error: operationError)
		}

		// find Credential authenticator
		guard let authenticators = mobileAuthenticationClient?.localData.authenticators else {
			let operationError = OperationError(operation: operation,
			                                    underlyingError: authenticatorNotFoundError)
			return errorHandlerChain.handle(error: operationError)
		}

		guard let credentialAuthenticator = authenticators.filter({ $0.aaid == authenticatorType.rawValue }).first else {
			let operationError = OperationError(operation: operation,
			                                    underlyingError: authenticatorNotFoundError)
			return errorHandlerChain.handle(error: operationError)
		}

		guard let enrollment = credentialAuthenticator.userEnrollment as? SdkUserEnrollment else {
			let operationError = OperationError(operation: operation,
			                                    underlyingError: authenticatorNotFoundError)
			return errorHandlerChain.handle(error: operationError)
		}

		let eligibleAccounts = accounts.filter { account in
			enrollment.enrolledAccounts.contains { enrolledAccount in
				enrolledAccount.username == account.username
			}
		}

		switch eligibleAccounts.count {
		case 0:
			let operationError = OperationError(operation: operation,
			                                    underlyingError: AppError.accountsNotFound)
			return errorHandlerChain.handle(error: operationError)
		case 1 where authenticatorType == .Pin:
			// do PIN change automatically
			doPinChange(for: eligibleAccounts.first!.username)
		case 1 where authenticatorType == .Password:
			// do PIN change automatically
			doPasswordChange(for: eligibleAccounts.first!.username)
		default:
			// in case of multiple eligible accounts we have to show the account selection screen
			let parameter: SelectAccountParameter = .select(accounts: eligibleAccounts,
			                                                operation: operation,
			                                                handler: nil,
			                                                message: nil)
			appCoordinator.navigateToAccountSelection(with: parameter)
		}
	}

	/// Starts device information change operation.
	func changeDeviceInformation() {
		let deviceInformation = mobileAuthenticationClient?.localData.deviceInformation
		guard let deviceInformation else {
			logger.sdk("Device information not found.", .red)
			let operationError = OperationError(operation: .deviceInformationChange,
			                                    underlyingError: AppError.deviceInformationNotFound)
			return errorHandlerChain.handle(error: operationError)
		}

		let parameter: ChangeDeviceInformationParameter = .change(deviceInformation: deviceInformation)
		appCoordinator.navigateToChangeDeviceInformation(with: parameter)
	}

	/// Starts Auth Cloud API registration operation.
	func authCloudApiRegister() {
		appCoordinator.navigateToAuthCloudApiRegistration()
	}

	/// Deletes local authenticators.
	func deleteLocalAuthenticators() {
		// find enrolled accounts
		guard let accounts = mobileAuthenticationClient?.localData.accounts, !accounts.isEmpty else {
			logger.sdk("Accounts not found.", .red)
			let operationError = OperationError(operation: .localData,
			                                    underlyingError: AppError.accountsNotFound)
			return errorHandlerChain.handle(error: operationError)
		}

		doDeleteAuthenticators(of: accounts.map(\.username)) { result in
			switch result {
			case .success:
				logger.sdk("Delete authenticators succeeded.", .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .localData))
			case let .failure(error):
				logger.sdk("Delete authenticators failed.", .red)
				let operationError = OperationError(operation: .localData, underlyingError: error)
				self.errorHandlerChain.handle(error: operationError)
			}
		}
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
			logger.sdk("Deregistration succeeded.", .green)
			return appCoordinator.navigateToResult(with: .success(operation: .deregistration))
		}

		mobileAuthenticationClient?.operations.deregistration
			.username(username)
			.onSuccess {
				logger.sdk("Deregistration succeeded for user %@", .green, .debug, username)
				self.doDeregistration(for: remainingUsernames)
			}
			.onError {
				logger.sdk("Deregistration failed for user %@", .red, .debug, username)
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
				logger.sdk("PIN change succeeded.", .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .pinChange))
			}
			.onError {
				logger.sdk("PIN change failed.", .red)
				let operationError = OperationError(operation: .pinChange, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Starts the Password change operation.
	///
	/// - Parameter username: The username of the account whose PIN must be changed.
	func doPasswordChange(for username: String) {
		view?.disableInteraction()
		mobileAuthenticationClient?.operations.passwordChange
			.username(username)
			.passwordChanger(passwordChanger)
			.onSuccess {
				logger.sdk("Password change succeeded.", .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .passwordChange))
			}
			.onError {
				logger.sdk("Password change failed.", .red)
				let operationError = OperationError(operation: .passwordChange, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Deletes all local authenticators of all accounts.
	///
	/// - Parameters:
	///   - usernames: The usernames of the enrolled accounts.
	///   - handler: The code need to be executed after deletion.
	func doDeleteAuthenticators(of usernames: [Username], completion handler: @escaping (Result<(), Error>) -> ()) {
		var remainingUsernames = usernames
		guard let username = remainingUsernames.popLast() else {
			return handler(.success)
		}

		doDeleteAuthenticators(of: username) { result in
			if case let .failure(error) = result {
				return handler(.failure(error))
			}
			logger.sdk("Delete authenticators succeeded for user %@.", .green, .debug, username)
			self.doDeleteAuthenticators(of: remainingUsernames, completion: handler)
		}
	}

	/// Deletes all local authenticators of an account.
	///
	/// - Parameters:
	///   - usernames: The username of the enrolled account.
	///   - handler: The code need to be executed after deletion.
	func doDeleteAuthenticators(of username: Username, completion handler: @escaping (Result<(), Error>) -> ()) {
		DispatchQueue.global().async {
			do {
				try self.mobileAuthenticationClient?.localData.deleteAuthenticator(username: username, aaid: nil)
				DispatchQueue.main.async {
					handler(.success)
				}
			}
			catch {
				DispatchQueue.main.async {
					handler(.failure(error))
				}
			}
		}
	}
}
