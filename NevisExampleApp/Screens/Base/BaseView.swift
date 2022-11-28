//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// This protocol describes the generic capabilities shared between all views of an application.
protocol BaseView where Self: UIViewController {

	/// Disables interaction on the view (e.g. when a server call is in progress).
	func disableInteraction()

	/// Re-enables user interaction on the view.
	func enableInteraction()
}

/// Default implementation of the ``BaseView`` protocol.
extension BaseView {

	func disableInteraction() {
		showLoading()
	}

	func enableInteraction() {
		dismissLoading()
	}
}
