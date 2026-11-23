//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import WatchConnectivity

/// Default implementation of `WatchSessionDelegate`.
///
/// Decodes the `WatchMessage`s of the watch app, lets `WatchMessageHandler` process them and replies with the
/// resulting `PhoneMessage`.
final class WatchSessionDelegateImpl: NSObject, Sendable {
	// MARK: - Properties

	/// Processes the received messages.
	private let messageHandler: WatchMessageHandler

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter messageHandler: Processes the received messages.
	init(messageHandler: WatchMessageHandler) {
		self.messageHandler = messageHandler
	}
}

// MARK: - WatchSessionDelegate

extension WatchSessionDelegateImpl: WatchSessionDelegate {
	func activate() {
		guard WCSession.isSupported() else {
			logger.app("WatchConnectivity is not supported.")
			return
		}

		WCSession.default.delegate = self
		WCSession.default.activate()
	}
}

// MARK: - WCSessionDelegate

extension WatchSessionDelegateImpl: WCSessionDelegate {
	func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let error {
			logger.app("Watch session activation failed: %@", .red, .error, error.localizedDescription)
			return
		}

		logger.app("Watch session activated with state: %d", .purple, .debug, activationState.rawValue)
	}

	/// Required by `WCSessionDelegate`. No action needed before `sessionDidDeactivate(_:)` reactivates.
	func sessionDidBecomeInactive(_: WCSession) {}

	/// Reactivate so a newly-paired watch can connect.
	func sessionDidDeactivate(_: WCSession) {
		WCSession.default.activate()
	}

	func session(_: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> ()) {
		// WCSession calls the delegate on a background queue and the reply handler is not Sendable.
		// It is safe to hand it over: only the task uses it after this point, it can be called from any thread,
		// and it is called exactly once on every path, as WatchConnectivity requires.
		nonisolated(unsafe) let replyHandler = replyHandler
		Task { @MainActor in
			let reply: PhoneMessage
			do throws(WatchError) {
				let message = try MessageCoder.decode(WatchMessage.self, from: messageData)
				reply = await messageHandler.handle(message)
			} catch {
				reply = .failed(error)
			}

			replyHandler(Self.encode(reply))
		}
	}
}

// MARK: - Private Interface

private extension WatchSessionDelegateImpl {
	/// Encodes the reply. Falls back to `WatchError.invalidMessage` if the reply cannot be encoded.
	///
	/// - Parameter reply: The reply to encode.
	/// - Returns: The encoded reply.
	static func encode(_ reply: PhoneMessage) -> Data {
		do throws(WatchError) {
			return try MessageCoder.encode(reply)
		} catch {
			return (try? MessageCoder.encode(PhoneMessage.failed(error))) ?? Data()
		}
	}
}
