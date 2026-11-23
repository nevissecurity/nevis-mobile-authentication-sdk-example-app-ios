//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation
import NevisExampleShared

/// Async wrapper around the SDK operations used by the extension.
@MainActor
protocol AuthenticationService {
	/// Loads the configuration and initializes the SDK client in companion mode. No-op if already initialized.
	///
	/// - Throws: ``ExtensionError/configuration`` or the SDK initialization error.
	func initialize() async throws

	/// The registered accounts with their usable authenticators. Empty before initialization.
	///
	/// - Returns: The accounts.
	func accounts() -> [RegisteredAccount]

	/// Authenticates the account with the given authenticator.
	///
	/// - Parameters:
	///   - username: The account to authenticate.
	///   - authenticator: The authenticator to use for authentication.
	///   - credentialProvider: Asks the UI for the PIN or password.
	/// - Returns: The issued JWT; `nil` for cookie-based setups.
	/// - Throws: ``AuthenticationServiceError/notInitialized``, ``HeadlessAuthenticationError`` or the SDK error.
	func authenticate(_ username: String, using authenticator: AuthenticatorKind, credentialProvider: @escaping CredentialProvider) async throws -> String?

	/// Deletes the given authenticator of the given account from the device.
	/// The registration on the server is not removed.
	///
	/// - Parameters:
	///   - username: The account used for deletion.
	///   - authenticator: The authenticator to delete.
	/// - Throws: ``AuthenticationServiceError/notInitialized`` or the SDK error.
	func delete(username: String, authenticator: AuthenticatorKind) async throws
}
