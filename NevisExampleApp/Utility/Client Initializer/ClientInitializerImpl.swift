//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

@MainActor
final class ClientInitializerImpl {
	// MARK: - Properties

	/// The configuration loader.
	private let configurationLoader: ConfigurationLoader

	/// The client provider.
	private let clientProvider: ClientProvider

	private var task: Task<Void, Error>?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - configurationLoader: The configuration loader.
	///   - clientProvider: The client provider.
	init(
		configurationLoader: ConfigurationLoader,
		clientProvider: ClientProvider,
	) {
		self.configurationLoader = configurationLoader
		self.clientProvider = clientProvider
	}
}

extension ClientInitializerImpl: ClientInitializer {
	func initialize() async throws {
		if clientProvider.get() != nil {
			return
		}

		if let task {
			return try await task.value
		}

		let task = Task { try await doInitialize() }
		self.task = task
		defer { self.task = nil }
		try await task.value
	}
}

private extension ClientInitializerImpl {
	func doInitialize() async throws {
		guard let configuration = try configurationLoader.load() else {
			throw AppError.loadAppConfigurationError
		}

		logger.sdk("Initializing client.")
		try await withCheckedThrowingContinuation { continuation in
			MobileAuthenticationClientInitializer()
				.configuration(configuration.sdkConfiguration)
				.onSuccess { client in
					Task { @MainActor in
						self.clientProvider.save(client: client)
						continuation.resume()
					}
				}
				.onError { continuation.resume(throwing: $0) }
				.execute()
		}
	}
}
