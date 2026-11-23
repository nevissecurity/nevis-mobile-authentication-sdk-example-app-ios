//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024. Nevis Security AG. All rights reserved.
//

import Foundation
import NevisExampleShared
import NevisMobileAuthentication

/// Codable extension for `AuthenticatorAaid`.
extension AuthenticatorAaid: @retroactive Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let aaid = try container.decode(String.self)
		guard let authenticatorAaid = AuthenticatorAaid(rawValue: aaid) else {
			throw NSError(domain: "AuthenticatorAaid cannot be decoded", code: 1)
		}
		self = authenticatorAaid
	}

	/// The platform independent representation of the authenticator. `nil` for an unknown AAID.
	var kind: AuthenticatorKind? {
		AuthenticatorKind(rawValue: rawValue)
	}

	/// Returns the localized title.
	var localizedTitle: String {
		kind?.localizedTitle ?? String()
	}
}

extension AuthenticatorAaid {
	/// Returns a Boolean value indicating whether a `String` and an `AuthenticatorAaid` are equal.
	///
	/// - Parameters:
	///   - lhs: A `String` value to compare.
	///   - rhs: An `AuthenticatorAaid` to compare.
	/// - Returns: A Boolean value indicating whether the two values are equal.
	static func == (lhs: String, rhs: AuthenticatorAaid) -> Bool {
		rhs.rawValue == lhs
	}

	/// Returns a Boolean value indicating whether a `String` and an `AuthenticatorAaid` are equal.
	///
	/// - Parameters:
	///   - lhs: An `AuthenticatorAaid` to compare.
	///   - rhs: A `String` value to compare.
	/// - Returns: A Boolean value indicating whether the two values are equal.
	static func == (lhs: AuthenticatorAaid, rhs: String) -> Bool {
		rhs == lhs.rawValue
	}
}
