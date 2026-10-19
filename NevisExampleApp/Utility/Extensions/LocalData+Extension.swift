//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

extension LocalData {
	/// Returns the registered accounts with the authenticators they can use for authentication.
	///
	/// Used where the SDK types cannot be used directly: in the share extension UI and in the messages sent to the watch.
	///
	/// - Parameter allowlist: The authenticators allowed by the configuration.
	/// - Returns: The registered accounts.
	func registeredAccounts(allowlist: [AuthenticatorAaid]) -> [RegisteredAccount] {
		accounts.map {
			RegisteredAccount(
				username: $0.username,
				authenticators: authenticators.usableKinds(for: $0.username, allowlist: allowlist)
			)
		}
	}
}
