//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared

/// Protocol declaration for the watch side of the WatchConnectivity session.
///
/// The watch app cannot use the SDK, it sends `WatchMessage`s to the iPhone app, which replies with `PhoneMessage`s.
protocol PhoneSession: AnyObject {
	/// Emits the reachability of the iPhone app whenever it changes.
	var reachabilityUpdates: AsyncStream<Bool> { get }

	/// Emits the messages pushed by the iPhone app, e.g. the progress of an authentication.
	var messages: AsyncStream<PhoneMessage> { get }

	/// Activates the session. Must be called on launch.
	func activate()

	/// Sends a message to the iPhone app and waits for its reply. Waits for the activation first, if it is in progress.
	///
	/// - Parameter message: The message to send.
	/// - Returns: The reply of the iPhone app.
	/// - Throws: `WatchError` if the message could not be delivered or the reply is invalid.
	func send(_ message: WatchMessage) async throws(WatchError) -> PhoneMessage
}
