//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Change Device Information view.
final class ChangeDeviceInformationScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.ChangeDeviceInformation.title, style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(style: .normal)

	/// The text field for the new device name.
	private let nameField = NSTextField(placeholder: L10n.ChangeDeviceInformation.namePlaceholder)

	/// The error label.
	private let errorLabel = NSLabel(style: .error)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.ChangeDeviceInformation.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.ChangeDeviceInformation.cancel)

	// MARK: - Properties

	/// The presenter.
	var presenter: ChangeDeviceInformationPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: ChangeDeviceInformationPresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	deinit {
		logger.deinit("ChangeDeviceInformationScreen")
	}
}

// MARK: - Lifecycle

extension ChangeDeviceInformationScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	/// Override of the `viewWillAppear(_:)` lifecycle method. Sets up the text fields.
	///
	/// - parameter animated: If *true*, the view is being added to the window using an animation.
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setupTextFields()
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

private extension ChangeDeviceInformationScreen {

	func setupUI() {
		setupTitleLabel()
		setupDescriptionLabel()
		setupNameField()
		setupErrorLabel()
		setupConfirmButton()
		setupCancelButton()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, topSpacing: 32)
		}
	}

	func setupDescriptionLabel() {
		descriptionLabel.do {
			addItem($0, topSpacing: 32)
			$0.text = presenter.getName()
		}
	}

	func setupNameField() {
		nameField.do {
			addItem($0, topSpacing: 32)
			$0.setHeight(with: 40)
			$0.delegate = self
		}
	}

	func setupErrorLabel() {
		errorLabel.do {
			addItem($0, topSpacing: 5)
			$0.text = L10n.ChangeDeviceInformation.missingName
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

	func setupTextFields() {
		nameField.becomeFirstResponder()
	}
}

// MARK: - UITextFieldDelegate

extension ChangeDeviceInformationScreen: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
}

// MARK: - Actions

private extension ChangeDeviceInformationScreen {

	@objc
	func confirm() {
		guard let name = nameField.text, !name.isEmpty else {
			errorLabel.superview?.isHidden = false
			return
		}

		errorLabel.superview?.isHidden = true
		presenter.change(name: name)
	}

	@objc
	func cancel() {
		presenter.cancel()
	}
}
