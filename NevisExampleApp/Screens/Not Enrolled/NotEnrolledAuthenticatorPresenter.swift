//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Presenter of Not Enrolled Authenticator view.
final class NotEnrolledAuthenticatorPresenter {

	// MARK: - Properties

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter appCoordinator: The application coordinator.
	init(appCoordinator: AppCoordinator) {
		self.appCoordinator = appCoordinator
	}
}

// MARK: - Public Interface

extension NotEnrolledAuthenticatorPresenter {

	/// Navigates back to the Home screen.
	func doAction() {
		appCoordinator.start()
	}
}
