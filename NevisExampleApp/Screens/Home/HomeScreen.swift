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

	/// The Password Change button.
	private let passwordChangeButton = OutlinedButton(title: L10n.Home.changePassword)

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

	/// The title label of Nevis Mobile Authentication SDK version.
	private let versionTitleLabel = NSLabel(text: L10n.Home.sdkVersion, style: .normal)

	/// The value label of Nevis Mobile Authentication SDK version.
	private let versionValueLabel = NSLabel(style: .info)

	/// The title label of application facet identifier.
	private let facetIdTitleLabel = NSLabel(text: L10n.Home.facetId, style: .normal)

	/// The value label of application facet identifier.
	private let facetIdValueLabel = NSLabel(style: .info)

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

	deinit {
		logger.deinit("HomeScreen")
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
			self.versionValueLabel.text = self.presenter.sdkVersion()
			self.facetIdValueLabel.text = self.presenter.facetId()
		}
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

private extension HomeScreen {

	func setupUI() {
		setupTitleLabel()
		setupDescriptionLabel()
		setupReadQrCodeButton()
		setupAuthenticateButton()
		setupDeregisterButton()
		setupPinChangeButton()
		setupPasswordChangeButton()
		setupChangeDeviceInformationButton()
		setupAuthCloudApiRegisterButton()
		setupDeleteAuthenticatorsButton()
		setupSeparatorLabel()
		setupInBandRegisterButton()
		setupVersionLabels()
		setupFacetIdLabels()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, topSpacing: 30)
		}
	}

	func setupDescriptionLabel() {
		descriptionLabel.do {
			addItem($0, spacing: 16, topSpacing: 30)
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

	func setupPasswordChangeButton() {
		passwordChangeButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
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

	func setupVersionLabels() {
		versionTitleLabel.do {
			addItemToBottom($0, spacing: 8)
		}

		versionValueLabel.do {
			addItemToBottom($0, spacing: 16)
		}
	}

	func setupFacetIdLabels() {
		facetIdTitleLabel.do {
			addItemToBottom($0, spacing: 8)
		}

		facetIdValueLabel.do {
			addItemToBottom($0, spacing: 16)
		}
	}
}

// MARK: - Actions

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
		presenter.changeCredential(.Pin)
	}

	@objc
	func changePassword() {
		presenter.changeCredential(.Password)
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
