//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

/// Protocol declaration for the iPhone side of the WatchConnectivity session.
protocol WatchSessionDelegate {
	/// Activates the default `WCSession` with this handler as its delegate. No-op if WatchConnectivity is unsupported on this device.
	///
	/// Must be called on launch, because the system may launch the app in the background to deliver a message of the watch app.
	func activate()
}
