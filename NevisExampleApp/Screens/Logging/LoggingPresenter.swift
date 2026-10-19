//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Presenter of Logging view.
@MainActor
final class LoggingPresenter {

	// MARK: - Properties

	/// The view of the presenter.
	weak var view: LoggingView?

	/// The observer of the log notifications. Set once in the initializer, removed on deinit.
	private nonisolated(unsafe) var observer: NSObjectProtocol?

	// MARK: - Initialization

	/// Creates a new instance.
	init() {
		// The logs are posted on the thread of the caller, deliver them on the main queue.
		observer = NotificationCenter.default.addObserver(forName: .log, object: nil, queue: .main) { [weak self] notification in
			// The message is not mutated after posting.
			nonisolated(unsafe) let message = notification.userInfo?[Notification.UserInfoKey.message] as? NSAttributedString
			MainActor.assumeIsolated {
				self?.log(message)
			}
		}
	}

	deinit {
		if let observer {
			NotificationCenter.default.removeObserver(observer)
		}
	}
}

// MARK: - Private Interface

private extension LoggingPresenter {

	/// Updates the view with the message sent with the log notification.
	///
	/// - Parameter message: The logged message.
	func log(_ message: NSAttributedString?) {
		guard let message else {
			return
		}

		view?.update(by: message)
	}
}
