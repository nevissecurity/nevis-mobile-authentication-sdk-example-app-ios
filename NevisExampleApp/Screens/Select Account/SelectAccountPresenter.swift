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
	///   - biometricUserVerifier: The biometric user verifier.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - logger: The logger.
	///   - parameter: The navigation parameter.
	init(clientProvider: ClientProvider,
	     authenticatorSelector: AuthenticatorSelector,
	     pinChanger: PinChanger,
	     pinUserVerifier: PinUserVerifier,
	     biometricUserVerifier: BiometricUserVerifier,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     logger: SDKLogger,
	     parameter: NavigationParameterizable) {
		self.clientProvider = clientProvider
		self.authenticatorSelector = authenticatorSelector
		self.pinChanger = pinChanger
		self.pinUserVerifier = pinUserVerifier
		self.biometricUserVerifier = biometricUserVerifier
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		self.logger = logger
		setParameter(parameter as? SelectAccountParameter)
	}

	/// :nodoc:
	deinit {
		os_log("SelectAccountPresenter", log: OSLog.deinit, type: .debug)
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
	/// - Parameter account: The account that must be used to authenticate.
	func inBandAuthenticate(using account: any Account, completion handler: ((Result<AuthorizationProvider?, Error>) -> ())? = nil) {
		mobileAuthenticationClient?.operations.authentication
			.username(account.username)
			.authenticatorSelector(authenticatorSelector)
			.pinUserVerifier(pinUserVerifier)
			.biometricUserVerifier(biometricUserVerifier)
			.onSuccess {
				self.logger.log("In-band authentication succeeded.", color: .green)
				if let cookieAuthorizationProvider = $0 as? CookieAuthorizationProvider {
					self.logger.log("Received cookies: \(cookieAuthorizationProvider.cookies)")
				}
				else if let jwtAuthorizationProvider = $0 as? JwtAuthorizationProvider {
					self.logger.log("Received JWT is \(jwtAuthorizationProvider.jwt)")
				}

				if let handler {
					return handler(.success($0))
				}

				self.appCoordinator.navigateToResult(with: .success(operation: self.operation!))
			}
			.onError {
				self.logger.log("In-band authentication failed.", color: .red)
				handler?(.failure($0))
				let operationError = OperationError(operation: .authentication, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Deregisters the given account.
	///
	/// - Parameter account: The account to deregister.
	func deregister(using account: any Account) {
		logger.log("Deregistering account: \(account)")

		// Deregistration (Identity Suite env) is in progress where the deregistration endpoint is guarded,
		// so an authorization provider is needed.
		// First perform In-Band authentication then a deregistration with the username.
		inBandAuthenticate(using: account) { result in
			switch result {
			case let .success(authorizationProvider):
				guard let authorizationProvider else {
					return self.errorHandlerChain.handle(error: AppError.cookieNotFound)
				}

				guard let authenticators = self.mobileAuthenticationClient?.localData.authenticators else {
					return self.appCoordinator.navigateToResult(with: .success(operation: .deregistration))
				}

				let registeredAuthenticators = authenticators.filter {
					$0.registration?.isRegistered(account.username) ?? false
				}

				self.doDeregistration(for: account.username,
				                      aaids: Set(registeredAuthenticators.map(\.aaid)),
				                      authorizationProvider: authorizationProvider)
			case .failure:
				self.logger.log("Deregistration failed for user \(account.username)", color: .red)
			}
		}
	}

	/// Deregisters all authenticators of a given account.
	///
	/// - Parameters:
	///   - accounts: The account to deregister.
	///   - aaids: The list of authenticator AAIDs to deregister.
	func doDeregistration(for username: String, aaids: Set<String>, authorizationProvider: AuthorizationProvider) {
		var remainingAaids = aaids
		guard let aaid = remainingAaids.popFirst() else {
			logger.log("Deregistration succeeded for user \(username)", color: .green)
			return appCoordinator.navigateToResult(with: .success(operation: operation!))
		}

		mobileAuthenticationClient?.operations.deregistration
			.username(username)
			.aaid(aaid)
			.authorizationProvider(authorizationProvider)
			.onSuccess {
				self.logger.log("Deregistration succeeded for authenticator with aaid \(aaid) for user \(username)", color: .green)
				self.doDeregistration(for: username,
				                      aaids: remainingAaids,
				                      authorizationProvider: authorizationProvider)
			}
			.onError {
				self.logger.log("Deregistration failed for user \(username)", color: .red)
				let operationError = OperationError(operation: .deregistration, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Changes the PIN of the selected account.
	///
	/// - Parameter account: The seleced account.
	func changePin(using account: any Account) {
		logger.log("Changing PIN for account: \(account)")
		view?.disableInteraction()
		mobileAuthenticationClient?.operations.pinChange
			.username(account.username)
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
}
