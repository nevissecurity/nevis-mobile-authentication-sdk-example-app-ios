//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Auth Cloud Api Registration view.
final class AuthCloudApiRegistrationScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.AuthCloudApiRegistration.title, style: .title)

	/// The text field for the enrollment response.
	private let enrollResponseField = NSTextField(placeholder: L10n.AuthCloudApiRegistration.enrollResponsePlaceholder)

	/// The text field for the app link URI.
	private let appLinkUriField = NSTextField(placeholder: L10n.AuthCloudApiRegistration.appLinkUriPlaceholder)

	/// The error label.
	private let errorLabel = NSLabel(style: .error)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.AuthCloudApiRegistration.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.AuthCloudApiRegistration.cancel)

	// MARK: - Properties

	/// The presenter.
	var presenter: AuthCloudApiRegistrationPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: AuthCloudApiRegistrationPresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	/// :nodoc:
	deinit {
		os_log("AuthCloudApiRegistrationScreen", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Lifecycle

extension AuthCloudApiRegistrationScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

/// :nodoc:
private extension AuthCloudApiRegistrationScreen {

	func setupUI() {
		setupTitleLabel()
		setupEnrollResponseField()
		setupAppLinkUriField()
		setupErrorLabel()
		setupConfirmButton()
		setupCancelButton()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, topSpacing: 32)
		}
	}

	func setupEnrollResponseField() {
		enrollResponseField.do {
			addItem($0, topSpacing: 32)
			$0.setHeight(with: 40)
		}
	}

	func setupAppLinkUriField() {
		appLinkUriField.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
		}
	}

	func setupErrorLabel() {
		errorLabel.do {
			addItem($0, topSpacing: 5)
			$0.superview?.isHidden = true
		}
	}

	func setupConfirmButton() {
		confirmButton.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
		}
	}

	func setupCancelButton() {
		cancelButton.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		}
	}
}

// MARK: - Actions

/// :nodoc:
private extension AuthCloudApiRegistrationScreen {

	@objc
	func confirm() {
		let validator = AuthCloudApiRegistrationValidator()
		let result = validator.validate(enrollResponseField.text, appLinkUriField.text)
		switch result {
		case .success:
			errorLabel.superview?.isHidden = true
			presenter.register(enrollResponse: enrollResponseField.text, appLinkUri: appLinkUriField.text)
		case let .failure(error):
			errorLabel.text = error.localizedDescription
			errorLabel.superview?.isHidden = false
		}
	}

	@objc
	func cancel() {
		presenter.cancel()
	}
}
