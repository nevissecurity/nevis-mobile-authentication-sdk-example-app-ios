//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// ``AuthenticationService`` backed by the Nevis Mobile Authentication SDK.
@MainActor
final class AuthenticationServiceImpl {
	// MARK: - Properties

	/// Loads the configuration shared with the containing app.
	private let configurationLoader: ConfigurationLoader
	/// The loaded configuration; `nil` before initialization.
	private var appConfiguration: AppConfiguration?
	/// The SDK client; `nil` before initialization.
	private var client: MobileAuthenticationClient?

	// MARK: - Initialization

	/// Creates the service.
	///
	/// - Parameter configurationLoader: Loads the configuration shared with the containing app.
	init(configurationLoader: ConfigurationLoader) {
		self.configurationLoader = configurationLoader
	}
}

// MARK: - AuthenticationService

extension AuthenticationServiceImpl: AuthenticationService {
	func initialize() async throws {
		if client != nil {
			return
		}

		guard let appConfiguration = try configurationLoader.load() else {
			throw ExtensionError.configuration
		}

		self.appConfiguration = appConfiguration
		try await withCheckedThrowingContinuation { continuation in
			MobileAuthenticationClientInitializer()
				.configuration(appConfiguration.sdkConfiguration)
				.onSuccess { client in
					Task { @MainActor in
						self.client = client
						continuation.resume()
					}
				}
				.onError { continuation.resume(throwing: $0) }
				.execute()
		}
	}

	func accounts() -> [RegisteredAccount] {
		guard let client else {
			return []
		}

		return client.localData.registeredAccounts(allowlist: appConfiguration?.authenticatorAllowlist ?? [])
	}

	func authenticate(_ username: String, using authenticator: AuthenticatorKind, credentialProvider: @escaping CredentialProvider) async throws -> String? {
		guard let client else {
			throw AuthenticationServiceError.notInitialized
		}

		return try await HeadlessAuthentication.authenticate(
			username,
			using: authenticator,
			client: client,
			allowlist: appConfiguration?.authenticatorAllowlist ?? [],
			credentialProvider: credentialProvider
		)
	}

	func delete(username: String, authenticator: AuthenticatorKind) async throws {
		guard let client else {
			throw AuthenticationServiceError.notInitialized
		}

		try await Task.detached {
			try client.localData.deleteAuthenticator(username: username, aaid: authenticator.aaid)
		}.value
	}
}
