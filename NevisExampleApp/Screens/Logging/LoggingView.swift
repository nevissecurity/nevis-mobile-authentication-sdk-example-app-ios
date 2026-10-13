//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// View protocol for the ``LoggingScreen``.
@MainActor
protocol LoggingView: AnyObject {

	/// Updates the view with the message.
	///
	/// - Parameter message: The message.
	func update(by message: NSAttributedString)
}
