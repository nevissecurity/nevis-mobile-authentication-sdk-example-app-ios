//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import AVFoundation
import MercariQRScanner
import UIKit

/// The Qr Scanner view.
final class QrScannerScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The Qr Scanner view.
	private var qrScannerView: QRScannerView?

	// MARK: - Properties

	/// The presenter.
	var presenter: QrScannerPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: QrScannerPresenter) {
		super.init()
		self.presenter = presenter
	}

	deinit {
		logger.deinit("QrScannerScreen")
	}
}

// MARK: - Lifecycle

extension QrScannerScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	/// Override of the `viewDidDisappear(_:)` lifecycle method.
	///
	/// - parameter animated: If *true*, the view is being removed from the window using an animation.
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		qrScannerView?.stopRunning()
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

private extension QrScannerScreen {

	func setupUI() {
		setupQRScanner()
	}

	func setupQRScanner() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			setupQRScannerView()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
				if granted {
					DispatchQueue.main.async { [weak self] in
						self?.setupQRScannerView()
					}
				}
			}
		default:
			showAlert()
		}
	}

	func setupQRScannerView() {
		qrScannerView = QRScannerView(frame: view.bounds)
		view.addSubview(qrScannerView!)
		qrScannerView?.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
		qrScannerView?.startRunning()
	}

	func showAlert() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			let alert = UIAlertController(title: L10n.Error.QrCodeScan.title,
			                              message: L10n.Error.QrCodeScan.Unauthorized.message,
			                              preferredStyle: .alert)
			alert.addAction(.init(title: L10n.Error.QrCodeScan.confirm, style: .default))
			self?.present(alert, animated: true)
		}
	}
}

// MARK: - QRScannerViewDelegate

extension QrScannerScreen: QRScannerViewDelegate {

	func qrScannerView(_: QRScannerView, didFailure error: QRScannerError) {
		print(error.localizedDescription)
	}

	func qrScannerView(_: QRScannerView, didSuccess code: String) {
		presenter.handle(code: code)
	}

	func qrScannerView(_: QRScannerView, didChangeTorchActive _: Bool) {}
}
