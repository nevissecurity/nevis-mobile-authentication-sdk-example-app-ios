//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Combine
import NevisMobileAuthentication

/// Default implementation of ``ClientProvider`` protocol.
class ClientProviderImpl {

	// MARK: - Properties

	/// The client.
	private var client: MobileAuthenticationClient?

	/// Publishes the current `MobileAuthenticationClient` and subsequent updates.
	private let clientPublisher = CurrentValueSubject<MobileAuthenticationClient?, Never>(nil)
}

// MARK: - ClientProvider

extension ClientProviderImpl: ClientProvider {

	func save(client: MobileAuthenticationClient) {
		self.client = client
		clientPublisher.send(client)
	}

	func get() -> MobileAuthenticationClient? {
		client
	}

	func resolve() -> AnyPublisher<MobileAuthenticationClient?, Never> {
		clientPublisher.eraseToAnyPublisher()
	}

	func reset() {
		client = nil
	}
}
