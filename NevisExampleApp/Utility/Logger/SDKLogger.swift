//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// Protocol describing SDK events related logging operations.
protocol SDKLogger {

	/// Logs a message.
	///
	/// - Parameter message: The message need to be log.
	func log(_ message: String)

	/// Logs a message using the specified color.
	///
	/// - Parameters:
	///   - message: The message need to be log.
	///   - color: The color need to be applied.
	func log(_ message: String, color: UIColor)
}
