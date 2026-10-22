//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared

/// Protocol declaration for pushing messages to the watch app.
///
/// Used to report the progress of an authentication, which can take longer than the reply timeout of a `WatchMessage`.
protocol WatchMessageSender: Sendable {
	/// Sends a message to the watch app and waits until the watch app acknowledges it.
	///
	/// - Parameter message: The message to send.
	/// - Throws: `WatchError` if the message could not be delivered.
	func send(_ message: PhoneMessage) async throws(WatchError)
}
