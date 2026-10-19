//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared

/// The state of the watch app.
enum WatchState: Equatable {
	/// Loading the accounts from the iPhone app.
	case loading
	/// The registered accounts. Empty if no account is registered in the iPhone app.
	case accounts([RegisteredAccount])
	/// The accounts could not be loaded.
	case failed(WatchError)
}
