//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Presenter of Logging view.
final class LoggingPresenter {

	// MARK: - Properties

	/// The logger.
	private let logger: SDKLogger

	/// The view of the presenter.
	weak var view: LoggingView?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter logger: The logger.
	init(logger: SDKLogger) {
		self.logger = logger
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(log(_:)),
		                                       name: .log,
		                                       object: nil)
	}

	/// :nodoc:
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Private Interface

private extension LoggingPresenter {

	/// Updates the view with the message sent with the notification.
	///
	/// - Parameter notification: The notification which holds the message.
	@objc
	func log(_ notification: Notification) {
		guard let userInfo = notification.userInfo,
		      let message = userInfo[Notification.UserInfoKey.message] as? NSAttributedString else {
			return
		}

		view?.update(by: message)
	}
}
