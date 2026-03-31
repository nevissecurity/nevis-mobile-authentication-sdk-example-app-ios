//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Object describing an operation error.
struct OperationError: Error {

	// MARK: - Properties

	/// The failed operation.
	let operation: Operation

	/// The underlying error.
	let underlyingError: Error
}
