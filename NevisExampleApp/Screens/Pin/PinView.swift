//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// View protocol for the ``PinScreen``.
protocol PinView: BaseView {

	/// Updates the view with the protection information.
	///
	/// - Parameter protectionInfo: The protection information.
	func update(by protectionInfo: PinProtectionInformation)
}
