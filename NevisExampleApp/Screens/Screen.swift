//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

/// By conforming to the protocol means that a presenter will be belong to the instance.
protocol Screen {

	/// Associated type for the presenter.
	associatedtype Presenter

	/// The presenter that belongs to the screen.
	var presenter: Presenter! { get set }

	/// Refreshes the screen.
	func refresh()
}
