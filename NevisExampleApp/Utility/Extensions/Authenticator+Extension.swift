//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Information about an authenticator.
extension Authenticator {
	/// Returns the localized title.
	var localizedTitle: String {
		guard let authenticatorAaid = AuthenticatorAaid(rawValue: aaid) else {
			return String()
		}

		return authenticatorAaid.localizedTitle
	}

	/// Returns whether the user is enrolled to this authenticator.
	///
	/// - Parameter username: the username.
	/// - Returns: `true` if the user is enrolled, `false` otherwise.
	func isEnrolled(username: Username) -> Bool {
		switch userEnrollment {
			case let enrollment as SdkUserEnrollment:
				enrollment.isEnrolled(username)
			case let enrollment as OsUserEnrollment:
				enrollment.isEnrolled()
			default:
				false
		}
	}

	/// Tells whether the authenticator can be used by the given account for authentication.
	///
	/// - Parameters:
	///   - username: The username of the account.
	///   - allowlist: The authenticators allowed by the configuration.
	/// - Returns: `true` if the authenticator is allowlisted, supported by the hardware and registered for `username`.
	func isUsable(by username: String, allowlist: [AuthenticatorAaid]) -> Bool {
		guard let aaid = AuthenticatorAaid(rawValue: aaid), allowlist.contains(aaid) else {
			return false
		}

		return isSupportedByHardware && registration.isRegistered(username)
	}
}

extension Array where Element == any Authenticator {
	/// Returns the authenticators the given account can use for authentication.
	///
	/// - Parameters:
	///   - username: The username of the account.
	///   - allowlist: The authenticators allowed by the configuration.
	/// - Returns: The usable authenticators, in `AuthenticatorKind.allCases` order.
	func usableKinds(for username: String, allowlist: [AuthenticatorAaid]) -> [AuthenticatorKind] {
		let aaids = Set(filter { $0.isUsable(by: username, allowlist: allowlist) }.map(\.aaid))
		return AuthenticatorKind.allCases.filter { aaids.contains($0.aaid) }
	}
}
