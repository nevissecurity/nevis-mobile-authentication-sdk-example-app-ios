//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Navigation parameter of the Select Authenticator view.
enum SelectAuthenticatorParameter: NavigationParameterizable {
	/// Represents authenticator selection.
	///
	///  - Parameters:
	///    - authenticatorItems: The list of authenticator items.
	///    - handler: The authenticator selection handler.
	case select(authenticatorItems: [AuthenticatorItem],
	            handler: AuthenticatorSelectionHandler)
}

/// Presenter of Authenticator Selection view.
final class SelectAuthenticatorPresenter {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The list of authenticator items.
	private var authenticatorItems = [AuthenticatorItem]()

	/// The authenticator selection handler.
	private var handler: AuthenticatorSelectionHandler?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	///   - parameter: The navigation parameter.
	init(appCoordinator: AppCoordinator,
	     parameter: NavigationParameterizable? = nil) {
		self.appCoordinator = appCoordinator
		setParameter(parameter as? SelectAuthenticatorParameter)
	}

	/// :nodoc:
	deinit {
		os_log("SelectAuthenticatorPresenter", log: OSLog.deinit, type: .debug)
		// If it is not nil at this moment, it means that a concurrent operation will be started.
		handler?.cancel()
	}
}

// MARK: - Public Interface

extension SelectAuthenticatorPresenter {

	/// Returns the list of authenticators.
	///
	/// - Returns: The list of authenticators.
	func getAuthenticators() -> [AuthenticatorItem] {
		authenticatorItems
	}

	/// Handles the selected authenticator.
	///
	/// - Parameter authenticator: The selected authenticator.
	func select(authenticator: any Authenticator) {
		handler?.aaid(authenticator.aaid)
		handler = nil
	}
}

// MARK: - Private Interface

private extension SelectAuthenticatorPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: SelectAuthenticatorParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .select(authenticatorItems, handler):
			self.authenticatorItems = authenticatorItems
			self.handler = handler
		}
	}
}
