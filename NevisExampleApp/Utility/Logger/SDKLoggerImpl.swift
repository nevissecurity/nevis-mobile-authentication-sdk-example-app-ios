//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// Default implementation of ``SDKLogger`` protocol.
final class SDKLoggerImpl {

	// MARK: - Properties

	/// Date formatter used during logging.
	private var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		return dateFormatter
	}
}

// MARK: - SDKLogger

extension SDKLoggerImpl: SDKLogger {

	func log(_ message: String) {
		log(message, color: .black)
	}

	func log(_ message: String, color: UIColor) {
		os_log("%@", log: OSLog.sdk, type: .debug, message)
		let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
		let attributedMessage = NSAttributedString(string: message,
		                                           attributes: attributes)

		let logMessage = NSMutableAttributedString(attributedString: NSAttributedString(string: "["))
		logMessage.append(NSAttributedString(string: dateFormatter.string(from: Date())))
		logMessage.append(NSAttributedString(string: "] "))
		logMessage.append(attributedMessage)
		logMessage.append(NSAttributedString(string: "\n"))
		NotificationCenter.default.post(name: .log,
		                                object: nil,
		                                userInfo: [Notification.UserInfoKey.message: logMessage])
	}
}
