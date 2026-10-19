//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// A request to enter a PIN or password.
public struct CredentialPrompt: Codable, Sendable, Equatable {
	// MARK: - Properties

	/// The kind of credential requested.
	public let kind: CredentialKind

	/// The account being authenticated.
	public let username: String

	/// The protection status of the authenticator.
	public let protection: CredentialProtection

	/// The localized remaining tries and cool down message. Empty if there is nothing to show.
	public var hint: String {
		protection.localizedDescription(for: kind)
	}

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - kind: The kind of credential requested.
	///   - username: The account being authenticated.
	///   - protection: The protection status of the authenticator.
	public init(kind: CredentialKind, username: String, protection: CredentialProtection) {
		self.kind = kind
		self.username = username
		self.protection = protection
	}

	// MARK: - Public Interface

	/// Returns when input is allowed again.
	///
	/// The cool down is transferred as a duration, because the clocks of the devices may differ.
	///
	/// - Parameter date: When the prompt was received.
	/// - Returns: The end of the cool down. `nil` if there is no cool down.
	public func coolDownEnd(from date: Date = .now) -> Date? {
		protection.coolDown > 0 ? date.addingTimeInterval(TimeInterval(protection.coolDown)) : nil
	}
}
