//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Navigation parameter of the Result view.
enum ResultParameter: NavigationParameterizable {
	/// Represents operation succeeded case.
	///
	///  - Parameter operation: The operation that finished successfully.
	case success(operation: Operation)

	/// Represents operation failed case.
	///
	///  - Parameter operation: The operation that failed.
	///  - Parameter description: The description of the failure.
	case failure(operation: Operation?, description: String?)
}

/// Presenter of Result view.
final class ResultPresenter {

	/// The available result types.
	private enum ResultType {
		/// Success result.
		case success
		/// Failure result.
		case failure
	}

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The type of the result.
	private var result: ResultType = .success

	/// The finished operation.
	private var operation: Operation?

	/// The description of the result.
	private var description: String?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - appCoordinator: The application coordinator.
	///   - parameter: The navigation parameter.
	init(appCoordinator: AppCoordinator,
	     parameter: NavigationParameterizable? = nil) {
		self.appCoordinator = appCoordinator
		setParameter(parameter as? ResultParameter)
	}

	deinit {
		logger.deinit("ResultPresenter")
	}
}

// MARK: - Public Interface

extension ResultPresenter {

	/// Returns the actual screen title based on the operation.
	///
	/// - Returns: The actual screen title based on the operation.
	func getTitle() -> String {
		switch result {
		case .success:
			return L10n.Operation.Success.title(operation!.localizedTitle)
		case .failure:
			guard let operation else {
				return L10n.Error.App.Generic.title
			}

			return L10n.Operation.Failed.title(operation.localizedTitle)
		}
	}

	/// Returns the actual screen description based on the operation.
	///
	/// - Returns: The actual screen description based on the operation.
	func getDescription() -> String? {
		description
	}

	/// Navigates back to the Home screen.
	func doAction() {
		appCoordinator.start()
	}
}

// MARK: - Private Interface

private extension ResultPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: ResultParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .success(operation):
			self.operation = operation
		case let .failure(operation, description):
			result = .failure
			self.operation = operation
			self.description = description
		}
	}
}
