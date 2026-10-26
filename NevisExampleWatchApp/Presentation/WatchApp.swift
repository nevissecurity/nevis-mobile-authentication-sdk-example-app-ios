//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI

/// The watch app.
@main
struct WatchApp: App {
	// MARK: - Properties

	/// The model of the screen.
	@State private var model: WatchModel

	// MARK: - Initialization

	init() {
		let session = PhoneSessionImpl()
		session.activate()
		_model = State(initialValue: WatchModel(session: session))
	}

	// MARK: - Body

	var body: some Scene {
		WindowGroup {
			WatchView(model: model)
		}
	}
}
