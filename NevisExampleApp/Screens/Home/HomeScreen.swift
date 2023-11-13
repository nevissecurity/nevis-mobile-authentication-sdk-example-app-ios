//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Home view. Starting view of the application.
final class HomeScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.Home.title, style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(style: .normal)

	/// The Read Qr Code button.
	private let readQrCodeButton = OutlinedButton(title: L10n.Home.readQrCode)

	/// The Authenticate button.
	private let authenticateButton = OutlinedButton(title: L10n.Home.authenticate)

	/// The Deregister button.
	private let deregisterButton = OutlinedButton(title: L10n.Home.deregister)

	/// The PIN Change button.
	private let pinChangeButton = OutlinedButton(title: L10n.Home.changePin)

	/// The Change Device Information button.
	private let changeDeviceInformationButton = OutlinedButton(title: L10n.Home.changeDeviceInformation)

	/// The Auth Cloud Api Register button.
	private let authCloudApiRegisterButton = OutlinedButton(title: L10n.Home.authCloudApiRegistration)

	/// The Delete Authenticators button.
	private let deleteAuthenticatorsButton = OutlinedButton(title: L10n.Home.deleteAuthenticators)

	/// The separator label.
	private let separatorLabel = NSLabel(text: L10n.Home.separator, style: .normal)

	/// The in-Band Register button.
	private let inBandRegisterButton = OutlinedButton(title: L10n.Home.inBandRegistration)

	// MARK: - Properties

	/// The presenter.
	var presenter: HomePresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: HomePresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	/// :nodoc:
	deinit {
		os_log("HomeScreen", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Lifecycle

extension HomeScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	/// Override of the `viewWillAppear(_:)` lifecycle method.
	///
	/// - parameter animated: If *true*, the view is being added to the window using an animation.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.initClient {
			self.descriptionLabel.text = L10n.Home.description(self.presenter.numberOfAccounts())
		}
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

/// :nodoc:
private extension HomeScreen {

	func setupUI() {
		setupTitleLabel()
		setupDescriptionLabel()
		setupReadQrCodeButton()
		setupAuthenticateButton()
		setupDeregisterButton()
		setupPinChangeButton()
		setupChangeDeviceInformationButton()
		setupAuthCloudApiRegisterButton()
		setupDeleteAuthenticatorsButton()
		setupSeparatorLabel()
		setupInBandRegisterButton()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, topSpacing: 30)
		}
	}

	func setupDescriptionLabel() {
		descriptionLabel.do {
			addItem($0, topSpacing: 30)
		}
	}

	func setupReadQrCodeButton() {
		readQrCodeButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(readQrCode), for: .touchUpInside)
		}
	}

	func setupAuthenticateButton() {
		authenticateButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
		}
	}

	func setupDeregisterButton() {
		deregisterButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(deregister), for: .touchUpInside)
		}
	}

	func setupPinChangeButton() {
		pinChangeButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(changePin), for: .touchUpInside)
		}
	}

	func setupChangeDeviceInformationButton() {
		changeDeviceInformationButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(changeDeviceInformation), for: .touchUpInside)
		}
	}

	func setupAuthCloudApiRegisterButton() {
		authCloudApiRegisterButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(authCloudApiRegister), for: .touchUpInside)
		}
	}

	func setupDeleteAuthenticatorsButton() {
		deleteAuthenticatorsButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(deleteAuthenticators), for: .touchUpInside)
		}
	}

	func setupSeparatorLabel() {
		separatorLabel.do {
			addItemToBottom($0, spacing: 8)
		}
	}

	func setupInBandRegisterButton() {
		inBandRegisterButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(register), for: .touchUpInside)
		}
	}
}

// MARK: - Actions

/// :nodoc:
private extension HomeScreen {

	@objc
	func readQrCode() {
		presenter.readQrCode()
	}

	@objc
	func authenticate() {
		presenter.authenticate()
	}

	@objc
	func deregister() {
		presenter.deregister()
	}

	@objc
	func changePin() {
		presenter.changePin()
	}

	@objc
	func changeDeviceInformation() {
		presenter.changeDeviceInformation()
	}

	@objc
	func authCloudApiRegister() {
		presenter.authCloudApiRegister()
	}

	@objc
	func deleteAuthenticators() {
		presenter.deleteLocalAuthenticators()
	}

	@objc
	func register() {
		presenter.register()
	}
}
