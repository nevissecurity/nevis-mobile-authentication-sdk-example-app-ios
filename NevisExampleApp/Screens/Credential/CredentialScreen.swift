//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Credential view. Used for PIN / Password creation verification and change.
class CredentialScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(style: .normal)

	/// The text field for the old credential.
	private let oldCredentialField = NSTextField(returnKeyType: .next)

	/// The text field for the credential.
	private let credentialField = NSTextField()

	/// The error label.
	private let errorLabel = NSLabel(style: .error)

	/// The information label.
	private let infoMessageLabel = NSLabel(style: .info)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.Credential.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.Credential.cancel)

	/// The toolbar for the keyboard with type *numberPad*.
	private let keyboardToolbar = UIToolbar()

	// MARK: - Properties

	/// The presenter.
	var presenter: CredentialPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: CredentialPresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	deinit {
		logger.deinit("CredentialScreen")
	}
}

// MARK: - Lifecycle

extension CredentialScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		refresh()
	}

	/// Override of the `viewWillAppear(_:)` lifecycle method. Sets up the text fields.
	///
	/// - parameter animated: If *true*, the view is being added to the window using an animation.
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setupTextFields()
	}

	func refresh() {
		errorLabel.text = presenter.getLastRecoverableError()
		update(by: presenter.getProtectionInfo())
	}
}

// MARK: - Setups

private extension CredentialScreen {

	func setupUI() {
		setupTitleLabel()
		setupDescriptionLabel()
		setupToolbar()
		setupOldPinField()
		setupPinField()
		setupErrorLabel()
		setupInfoMessageLabel()
		setupConfirmButton()
		setupCancelButton()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, topSpacing: 32)
			$0.text = presenter.getTitle()
		}
	}

	func setupDescriptionLabel() {
		descriptionLabel.do {
			addItem($0, topSpacing: 32)
			$0.text = presenter.getDescription()
		}
	}

	func setupToolbar() {
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
		                                target: nil,
		                                action: nil)
		let doneButton = UIBarButtonItem(title: L10n.Credential.done,
		                                 style: .done,
		                                 target: self,
		                                 action: #selector(done))
		keyboardToolbar.do {
			$0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
			$0.setItems([flexSpace, doneButton], animated: false)
			$0.sizeToFit()
		}
	}

	func setupOldPinField() {
		oldCredentialField.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.placeholder = presenter.getCredentialType() == .Pin ? L10n.Credential.Pin.oldPinPlaceholder : L10n.Credential.Password.oldPasswordPlaceholder
			$0.keyboardType = presenter.getCredentialType() == .Pin ? .numberPad : .default
			$0.isSecureTextEntry = true
			$0.inputAccessoryView = keyboardToolbar
			$0.superview?.isHidden = presenter.getOperation() != .credentialChange
		}
	}

	func setupPinField() {
		credentialField.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.placeholder = presenter.getCredentialType() == .Pin ? L10n.Credential.Pin.pinPlaceholder : L10n.Credential.Password.passwordPlaceholder
			$0.keyboardType = presenter.getCredentialType() == .Pin ? .numberPad : .default
			$0.isSecureTextEntry = true
			$0.inputAccessoryView = keyboardToolbar
		}
	}

	func setupErrorLabel() {
		errorLabel.do {
			addItem($0, topSpacing: 5)
		}
	}

	func setupInfoMessageLabel() {
		infoMessageLabel.do {
			addItem($0, topSpacing: 16)
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

	func setupTextFields() {
		if let superview = oldCredentialField.superview, !superview.isHidden {
			oldCredentialField.becomeFirstResponder()
		}
		else {
			credentialField.becomeFirstResponder()
		}
	}
}

// MARK: - CredentialView

extension CredentialScreen: CredentialView {

	func update(by protectionInfo: CredentialProtectionInformation) {
		infoMessageLabel.text = protectionInfo.message
		confirmButton.isEnabled = !protectionInfo.isInCoolDown
		cancelButton.isEnabled = !protectionInfo.isInCoolDown
	}
}

// MARK: - Actions

private extension CredentialScreen {

	@objc
	func done() {
		view.endEditing(true)
	}

	@objc
	func confirm() {
		if presenter.getOperation() == .credentialChange, oldCredentialField.text.isEmptyOrNil {
			errorLabel.text = presenter.getCredentialType() == .Pin ? L10n.Credential.Pin.missingOldPin : L10n.Credential.Password.missingOldPassword
			return
		}

		guard let credential = credentialField.text, !credential.isEmpty else {
			errorLabel.text = presenter.getCredentialType() == .Pin ? L10n.Credential.Pin.missingPin : L10n.Credential.Password.missingPassword
			return
		}

		errorLabel.text = nil
		presenter.confirm(oldCredential: oldCredentialField.text ?? String(), credential: credential)
	}

	@objc
	func cancel() {
		presenter.cancel()
	}
}
