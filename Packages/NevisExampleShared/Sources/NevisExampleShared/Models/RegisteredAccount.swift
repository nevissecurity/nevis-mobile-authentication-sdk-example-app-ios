//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// A registered account with its authenticators.
///
/// Named differently from the SDK's `Account`, so both can be used in the same file.
public struct RegisteredAccount: Codable, Sendable, Hashable, Identifiable {
	// MARK: - Properties

	/// The identifier of the account. The username, which is unique.
	public var id: String { username }

	/// The username of the account.
	public let username: String

	/// The authenticators the account can use.
	public let authenticators: [AuthenticatorKind]

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - username: The username of the account.
	///   - authenticators: The authenticators the account can use.
	public init(username: String, authenticators: [AuthenticatorKind]) {
		self.username = username
		self.authenticators = authenticators
	}
}
