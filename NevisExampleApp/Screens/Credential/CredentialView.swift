//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// View protocol for the ``CredentialScreen``.
protocol CredentialView: BaseView {

	/// Updates the view with the protection information.
	///
	/// - Parameter protectionInfo: The protection information.
	func update(by protectionInfo: CredentialProtectionInformation)
}
