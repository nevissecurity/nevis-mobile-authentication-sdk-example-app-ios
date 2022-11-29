//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Legacy Login view.
final class LegacyLoginScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.LegacyLogin.title, style: .title)

	/// The text field for the username.
	private let usernameField = NSTextField(placeholder: L10n.LegacyLogin.usernamePlaceholder, returnKeyType: .next)

	/// The text field for the password.
	private let passwordField = NSTextField(placeholder: L10n.LegacyLogin.passwordPlaceholder)

	/// The error label.
	private let errorLabel = NSLabel(style: .error)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.LegacyLogin.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.LegacyLogin.cancel)

	// MARK: - Properties

	/// The presenter.
	var presenter: LegacyLoginPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: LegacyLoginPresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	/// :nodoc:
	deinit {
		os_log("LegacyLoginScreen", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Lifecycle

extension LegacyLoginScreen {

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
private extension LegacyLoginScreen {

	func setupUI() {
		setupTitleLabel()
		setupUsernameField()
		setupPasswordField()
		setupErrorLabel()
		setupConfirmButton()
		setupCancelButton()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, topSpacing: 32)
		}
	}

	func setupUsernameField() {
		usernameField.do {
			addItem($0, topSpacing: 32)
			$0.setHeight(with: 40)
			$0.delegate = self
		}
	}

	func setupPasswordField() {
		passwordField.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.isSecureTextEntry = true
			$0.delegate = self
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

// MARK: - UITextFieldDelegate

/// :nodoc:
extension LegacyLoginScreen: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == usernameField {
			passwordField.becomeFirstResponder()
		}
		else {
			passwordField.resignFirstResponder()
		}
		return true
	}
}

// MARK: - Actions

/// :nodoc:
private extension LegacyLoginScreen {

	@objc
	func confirm() {
		let validator = LegacyLoginValidator()
		let result = validator.validate(usernameField.text, passwordField.text)
		switch result {
		case .success:
			errorLabel.superview?.isHidden = true
			presenter.login(username: usernameField.text!, password: passwordField.text!)
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
