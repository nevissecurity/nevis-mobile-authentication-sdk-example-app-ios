//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Navigation parameter of the Transaction Confirmation view.
enum TransactionConfirmationParameter: NavigationParameterizable {
	/// Represents transaction confirmation.
	///
	///  - Parameters:
	///    - message: The message to confirm.
	///    - account: The previously selected account.
	///    - handler: The account selection handler.
	case confirm(message: String, account: any Account, handler: AccountSelectionHandler)
}

/// Presenter of Transaction Confirmation view.
final class TransactionConfirmationPresenter {

	// MARK: - Properties

	/// The logger.
	private let logger: SDKLogger

	/// The transaction confirmation message.
	private var message: String?

	/// The previously selected account.
	private var account: (any Account)?

	/// The account selection handler.
	private var handler: AccountSelectionHandler?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - logger: The logger.
	///   - parameter: The navigation parameter.
	init(logger: SDKLogger,
	     parameter: NavigationParameterizable? = nil) {
		self.logger = logger
		setParameter(parameter as? TransactionConfirmationParameter)
	}

	/// :nodoc:
	deinit {
		os_log("TransactionConfirmationPresenter", log: OSLog.deinit, type: .debug)
		// If it is not nil at this moment, it means that a concurrent operation will be started.
		handler?.cancel()
	}
}

// MARK: - Public Interface

extension TransactionConfirmationPresenter {

	/// Returns the message to confirm.
	///
	/// - Returns: The message to confirm.
	func getMessage() -> String {
		message!
	}

	/// Confirms the transaction.
	func confirm() {
		handler?.username(account!.username)
		handler = nil
	}

	/// Cancels the transaction.
	func cancel() {
		handler?.cancel()
	}
}

// MARK: - Private Interface

private extension TransactionConfirmationPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: TransactionConfirmationParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .confirm(message, account, handler):
			self.message = message
			self.account = account
			self.handler = handler
		}
	}
}
