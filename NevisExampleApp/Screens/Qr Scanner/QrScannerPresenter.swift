//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// Presenter of Qr Scanner view.
final class QrScannerPresenter {

	// MARK: - Properties

	/// The Out-of-Band Operation handler.
	private let outOfBandOperationHandler: OutOfBandOperationHandler

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - outOfBandOperationHandler: The Out-of-Band Operation handler.
	init(outOfBandOperationHandler: OutOfBandOperationHandler) {
		self.outOfBandOperationHandler = outOfBandOperationHandler
	}

	deinit {
		logger.deinit("QrScannerPresenter")
	}
}

// MARK: - Public Interface

extension QrScannerPresenter {

	/// Decodes the given code and starts an Out-of-Band operation.
	///
	/// - Parameter code: The content of the read Qr code.
	func handle(code: String) {
		outOfBandOperationHandler.handle(payload: code)
	}
}
