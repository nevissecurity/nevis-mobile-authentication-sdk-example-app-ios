//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import WatchConnectivity

/// Default implementation of `WatchMessageSender` backed by the default `WCSession`.
struct WatchMessageSenderImpl: WatchMessageSender {
	func send(_ message: PhoneMessage) async throws(WatchError) {
		let reply = try await WCSession.default.send(message, replyType: PhoneMessage.self)
		if case let .failed(error) = reply {
			throw error
		}
	}
}
