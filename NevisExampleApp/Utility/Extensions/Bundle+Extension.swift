//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

extension Bundle {
	/// Whether this bundle is an app extension (`.appex`), as opposed to the containing app.
	var isAppExtension: Bool {
		bundleURL.pathExtension == "appex"
	}
}
