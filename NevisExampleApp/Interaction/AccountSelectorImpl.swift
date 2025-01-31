//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Default implementation of `AccountSelector` protocol.
/// For more information about account selection please read the [official documentation](https://docs.nevis.net/mobilesdk/guide/operation/authentication#account-selector).
///
/// First validates the accounts based on policy compliance. Then based on the number of accounts:
///  - if no account found, the SDK will raise an error.
///  - if one account found and the transaction confirmation data is present navigates to the ``TransactionConfirmationScreen``.
///  - if one account found and the transaction confirmation data is not present performs automatic account selection.
///  - if multiple account found navigates to the ``SelectAccountScreen``.
class AccountSelectorImpl {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	init(appCoordinator: AppCoordinator) {
		self.appCoordinator = appCoordinator
	}
}

// MARK: - AccountSelector

extension AccountSelectorImpl: AccountSelector {
	func selectAccount(context: AccountSelectionContext, handler: AccountSelectionHandler) {
		logger.sdk("Please select one of the received available accounts!")
		let validator = AccountValidator()
		let result = validator.validate(context: context)
		switch result {
		case let .success(validAccounts):
			switch validAccounts.count {
			case 0:
				// No username is compliant with the policy.
				// Provide a random username that will generate an error in the SDK.
				logger.sdk("No valid account found!", .red)
				handler.username("")
			case 1:
				if let transactionConfirmationData = context.transactionConfirmationData,
				   let message = String(data: transactionConfirmationData, encoding: .utf8) {
					let parameter: TransactionConfirmationParameter = .confirm(message: message,
					                                                           account: validAccounts.first!,
					                                                           handler: handler)
					appCoordinator.navigateToTransactionConfirmation(with: parameter)
				}
				else {
					// Typical case: authentication with username provided, just use it.
					logger.sdk("One account found, performing automatic selection!")
					handler.username(validAccounts.first!.username)
				}
			default:
				var transactionConfirmationDataString: String? {
					if let transactionConfirmationData = context.transactionConfirmationData {
						return String(data: transactionConfirmationData, encoding: .utf8)
					}

					return nil
				}

				let parameter: SelectAccountParameter = .select(accounts: validAccounts,
				                                                operation: .unknown,
				                                                handler: handler,
				                                                message: transactionConfirmationDataString)
				appCoordinator.navigateToAccountSelection(with: parameter)
			}
		case .failure:
			handler.cancel()
		}
	}
}
