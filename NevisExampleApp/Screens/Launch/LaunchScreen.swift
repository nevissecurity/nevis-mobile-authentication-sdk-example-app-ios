//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Launch view. Shown when the OS is loading the app.
final class LaunchScreen: BaseScreen, Screen {

	// MARK: - Properties

	/// The presenter.
	var presenter: LaunchPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: LaunchPresenter) {
		super.init()
		self.presenter = presenter
	}
}

// MARK: - Lifecycle

extension LaunchScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

/// :nodoc:
private extension LaunchScreen {

	func setupUI() {
		guard let splashViewController = UIStoryboard(name: "LaunchScreen", bundle: nil)
			.instantiateInitialViewController() else {
			return
		}

		addChild(splashViewController)
		view.addSubview(splashViewController.view)
		splashViewController.view.anchorToSuperView()
	}
}
