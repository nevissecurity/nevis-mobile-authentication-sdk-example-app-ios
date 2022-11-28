//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

extension Notification {

	/// Enumeration for supported user info keys.
	enum UserInfoKey {
		/// Represents a message.
		static let message = "message"
	}
}

extension Notification.Name {

	/// Name for logging related notifications.
	static let log = Notification.Name("log")
}
