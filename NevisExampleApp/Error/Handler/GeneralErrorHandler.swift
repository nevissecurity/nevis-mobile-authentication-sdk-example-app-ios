//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation
import NevisMobileAuthentication

/// The unique name of general error handler.
let GeneralErrorHandlerName = "error_handler_general"

/// An ``ErrorHandler`` implementation for general error handling.
final class GeneralErrorHandler {

	// MARK: - Properties

	/// The application coordinator.
	private let coordinator: AppCoordinator

	/// The logger.
	private let logger: SDKLogger

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - coordinator: The application coordinator.
	///   - logger: The logger.
	init(coordinator: AppCoordinator,
	     logger: SDKLogger) {
		self.coordinator = coordinator
		self.logger = logger
	}
}

// MARK: - ErrorHandler

extension GeneralErrorHandler: ErrorHandler {

	func handle(error: Error, chain: ErrorHandlerChain) {
		if error is OperationError {
			// error already handled
			chain.handle(error: error)
			return
		}

		logger.log("General error occurred: \(error.localizedDescription)", color: .red)

		coordinator.navigateToResult(with: .failure(operation: nil, description: error.localizedDescription))
		chain.handle(error: error)
	}
}
