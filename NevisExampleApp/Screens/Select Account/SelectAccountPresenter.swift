//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Navigation parameter of the Select Account view.
enum SelectAccountParameter: NavigationParameterizable {
	/// Represents account selection
	/// .
	///  - Parameters:
	///    - accounts: The list of accounts.
	///    - operation: The ongoing operation.
	///    - handler: The account selection handler.
	///    - message: The message to confirm.
	case select(accounts: [any Account],
	            operation: Operation,
	            handler: AccountSelectionHandler?,
	            message: String?)
}

/// Presenter of Account Selection view.
final class SelectAccountPresenter {

	// MARK: - Properties

	/// The view of the presenter.
	weak var view: BaseView?

	/// The client provider.
	private let clientProvider: ClientProvider

	/// The authenticator selector used during in-band authentication.
	private let authenticatorSelector: AuthenticatorSelector

	/// The PIN changer.
	private let pinChanger: PinChanger

	/// The PIN user verifier.
	private let pinUserVerifier: PinUserVerifier

	/// The Password changer.
	private let passwordChanger: PasswordChanger

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

	/// The list of accounts.
	private var accounts = [any Account]()

	/// The current operation.
	private var operation: Operation?

	/// The account seelction handler.
	private var handler: AccountSelectionHandler?

	/// The transaction confirmation data.
	private var transactionConfirmationData: String?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - clientProvider: The client provider.
	///   - authenticatorSelector: The authenticator selector used during in-band authentication.
	///   - pinChanger: The PIN changer.
	///   - pinUserVerifier: The PIN user verifier.
	///   - passwordChanger: The Password changer.
	///   - passwordUserVerifier: The Password user verifier.
	///   - biometricUserVerifier: The biometric user verifier.
	///   - devicePasscodeUserVerifier: The device passcode user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - parameter: The navigation parameter.
	init(clientProvider: ClientProvider,
	     authenticatorSelector: AuthenticatorSelector,
	     pinChanger: PinChanger,
	     pinUserVerifier: PinUserVerifier,
	     passwordChanger: PasswordChanger,
	     passwordUserVerifier: PasswordUserVerifier,
	     biometricUserVerifier: BiometricUserVerifier,
	     devicePasscodeUserVerifier: DevicePasscodeUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     parameter: NavigationParameterizable) {
		self.clientProvider = clientProvider
		self.authenticatorSelector = authenticatorSelector
		self.pinChanger = pinChanger
		self.pinUserVerifier = pinUserVerifier
		self.passwordChanger = passwordChanger
		self.passwordUserVerifier = passwordUserVerifier
		self.biometricUserVerifier = biometricUserVerifier
		self.devicePasscodeUserVerifier = devicePasscodeUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		setParameter(parameter as? SelectAccountParameter)
	}

	deinit {
		logger.deinit("SelectAccountPresenter")
		// If it is not nil at this moment, it means that a concurrent operation will be started.
		handler?.cancel()
	}
}

// MARK: - Public Interface

extension SelectAccountPresenter {

	/// Returns the available accounts.
	///
	/// - Returns: The available accounts.
	func getAccounts() -> [any Account] {
		accounts
	}

	/// Selects the given account.
	///
	/// - Parameter account: The selected account.
	func select(account: any Account) {
		if let transactionConfirmationData {
			// Transaction confirmation data is received from the SDK
			// Show it to the user for confirmation or cancellation
			// The AccountSelectionHandler will be invoked or cancelled there.
			return confirm(transaction: transactionConfirmationData, using: account)
		}

		switch operation {
		case .authentication:
			// in-band authentication is in progress (arriving from the Home screen)
			inBandAuthenticate(using: account)
		case .deregistration:
			deregister(using: account)
		case .pinChange:
			changePin(using: account)
		case .passwordChange:
			changePassword(using: account)
		default:
			handler?.username(account.username)
			handler = nil
		}
	}
}

// MARK: - Private Interface

private extension SelectAccountPresenter {

	/// Confirms the transaction.
	///
	/// - Parameters:
	///   - transaction: The transaction that need to be confirmed or cancelled by the user.
	///   - account: The current account.
	func confirm(transaction: String, using account: any Account) {
		let parameter: TransactionConfirmationParameter = .confirm(message: transaction,
		                                                           account: account,
		                                                           handler: handler!)
		appCoordinator.navigateToTransactionConfirmation(with: parameter)
		handler = nil
	}

	/// Starts an In-Band Authentication.
	///
	/// - Parameters:
	///   - account: The account that must be used to authenticate.
	///   - handler: An optional handler that should be executed when In-Band Authentication finished.
	func inBandAuthenticate(using account: any Account, completion handler: ((Result<AuthorizationProvider?, AuthenticationError>) -> ())? = nil) {
		mobileAuthenticationClient?.operations.authentication
			.username(account.username)
			.authenticatorSelector(authenticatorSelector)
			.pinUserVerifier(pinUserVerifier)
			.passwordUserVerifier(passwordUserVerifier)
			.biometricUserVerifier(biometricUserVerifier)
			.devicePasscodeUserVerifier(devicePasscodeUserVerifier)
			.onSuccess {
				logger.sdk("In-band authentication succeeded.", .green)
				self.printAuthorizationInfo($0)

				if let handler {
					return handler(.success($0))
				}

				self.appCoordinator.navigateToResult(with: .success(operation: self.operation!))
			}
			.onError { error in
				logger.sdk("In-band authentication failed.", .red)
				handler?(.failure(error))
				switch error {
				case let .FidoError(_, _, sessionProvider),
				     let .NetworkError(_, sessionProvider):
					self.printSessionInfo(sessionProvider)
				case .AppAttestationError(cause: _):
					fallthrough
				case .NoDeviceLockError:
					fallthrough
				case .Unknown:
					fallthrough
				@unknown default:
					logger.sdk("In-band authentication failed because of an unknown error.", .red)
				}

				let operationError = OperationError(operation: .authentication, underlyingError: error)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Deregisters the given account.
	///
	/// - Parameter account: The account to deregister.
	func deregister(using account: any Account) {
		logger.sdk("Deregistering account: %@", .black, .debug, account.username)

		// Deregistration (Identity Suite env) is in progress where the deregistration endpoint is guarded,
		// so an authorization provider is needed.
		// First perform In-Band authentication then a deregistration with the username.
		inBandAuthenticate(using: account) { result in
			switch result {
			case let .success(authorizationProvider):
				guard let authorizationProvider else {
					return self.errorHandlerChain.handle(error: AppError.cookieNotFound)
				}

				self.printAuthorizationInfo(authorizationProvider)
				self.doDeregistration(for: account.username, authorizationProvider: authorizationProvider)
			case .failure:
				logger.sdk("Deregistration failed for user %@", .black, .debug, account.username)
			}
		}
	}

	/// Deregisters all authenticators of a given account.
	///
	/// - Parameters:
	///   - username: The username of the account to deregister.
	///   - authorizationProvider: The authoriztion provider.
	func doDeregistration(for username: String, authorizationProvider: AuthorizationProvider) {
		mobileAuthenticationClient?.operations.deregistration
			.username(username)
			.authorizationProvider(authorizationProvider)
			.onSuccess {
				logger.sdk("Deregistration succeeded for user %@", .green, .debug, username)
				self.appCoordinator.navigateToResult(with: .success(operation: self.operation!))
			}
			.onError {
				logger.sdk("Deregistration failed for user %@", .red, .debug, username)
				let operationError = OperationError(operation: .deregistration, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Changes the PIN of the selected account.
	///
	/// - Parameter account: The seleced account.
	func changePin(using account: any Account) {
		logger.sdk("Changing PIN for account: %@", .black, .debug, account.username)
		view?.disableInteraction()
		mobileAuthenticationClient?.operations.pinChange
			.username(account.username)
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

	/// Changes the Password of the selected account.
	///
	/// - Parameter account: The seleced account.
	func changePassword(using account: any Account) {
		logger.sdk("Changing Password for account: %@", .black, .debug, account.username)
		view?.disableInteraction()
		mobileAuthenticationClient?.operations.passwordChange
			.username(account.username)
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

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: SelectAccountParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .select(accounts, operation, handler, transactionConfirmationData):
			self.accounts = accounts
			self.operation = operation
			self.handler = handler
			self.transactionConfirmationData = transactionConfirmationData
		}
	}

	/// Prints authorization information to the console.
	///
	/// - Parameter authorizationProvider: The ``AuthorizationProvider`` holding the authorization information.
	func printAuthorizationInfo(_ authorizationProvider: AuthorizationProvider?) {
		if let cookieAuthorizationProvider = authorizationProvider as? CookieAuthorizationProvider {
			logger.sdk("Received cookies: %@", .black, .debug, cookieAuthorizationProvider.cookies)
		}
		else if let jwtAuthorizationProvider = authorizationProvider as? JwtAuthorizationProvider {
			logger.sdk("Received JWT is %@", .black, .debug, jwtAuthorizationProvider.jwt)
		}
	}

	/// Prints session information to the console.
	///
	/// - Parameter sessionProvider: The ``SessionProvider`` holding the session information.
	func printSessionInfo(_ sessionProvider: SessionProvider?) {
		if let cookieSessionProvider = sessionProvider as? CookieSessionProvider {
			logger.sdk("Received cookies: %@", .black, .debug, cookieSessionProvider.cookies)
		}
		else if let jwtSessionProvider = sessionProvider as? JwtSessionProvider {
			logger.sdk("Received JWT is %@", .black, .debug, jwtSessionProvider.jwt)
		}
	}
}
