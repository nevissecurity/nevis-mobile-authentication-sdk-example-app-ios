//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared

/// Protocol declaration for processing the messages of the watch app.
@MainActor
protocol WatchMessageHandler: Sendable {
	/// Processes a message of the watch app.
	///
	/// Initializes the SDK client first if needed, because the system may launch the app in the background to deliver
	/// the message.
	///
	/// - Parameter message: The received message.
	/// - Returns: The reply to send back to the watch app.
	func handle(_ message: WatchMessage) async -> PhoneMessage
}
