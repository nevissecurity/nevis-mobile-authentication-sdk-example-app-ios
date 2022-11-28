//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Describes Out-of-Band Payload handling related operations.
protocol OutOfBandOperationHandler {

	/// Handles the given payload.
	///
	/// - Parameter payload: The payload to handle.
	func handle(payload: String)
}
