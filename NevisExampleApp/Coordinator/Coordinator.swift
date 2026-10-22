//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// Defines a simple coordinator contract for managing navigation and scene-level UI setup.
@MainActor
protocol Coordinator: AnyObject, Sendable {

	/// Starts the coordinator and sets up UI for the given scene.
	///
	/// - Parameter scene: The `UIWindowScene` to start the coordinator on.
	func start(on scene: UIWindowScene)
}
