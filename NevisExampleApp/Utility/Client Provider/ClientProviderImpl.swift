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

	/// Holds the current `MobileAuthenticationClient` and publishes its changes.
	private let clientSubject = CurrentValueSubject<MobileAuthenticationClient?, Never>(nil)
}

// MARK: - ClientProvider

extension ClientProviderImpl: ClientProvider {

	func save(client: MobileAuthenticationClient) {
		clientSubject.send(client)
	}

	func get() -> MobileAuthenticationClient? {
		clientSubject.value
	}

	func resolve() -> AnyPublisher<MobileAuthenticationClient?, Never> {
		clientSubject.eraseToAnyPublisher()
	}

	func reset() {
		clientSubject.send(nil)
	}
}
