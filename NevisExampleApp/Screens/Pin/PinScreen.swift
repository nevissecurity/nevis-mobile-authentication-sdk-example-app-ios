//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Pin view. Used for Pin code creation verification and change.
class PinScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(style: .normal)

	/// The text field for the old PIN.
	private let oldPinField = NSTextField(placeholder: L10n.Pin.oldPinPlaceholder, returnKeyType: .next)

	/// The text field for the PIN.
	private let pinField = NSTextField(placeholder: L10n.Pin.pinPlaceholder)

	/// The error label.
	private let errorLabel = NSLabel(style: .error)

	/// The information label.
	private let infoMessageLabel = NSLabel(style: .info)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.Pin.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.Pin.cancel)

	/// The toolbar for the keyboard with type *numberPad*.
	private let keyboardToolbar = UIToolbar()

	// MARK: - Properties

	/// The presenter.
	var presenter: PinPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: PinPresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	/// :nodoc:
	deinit {
		os_log("PinScreen", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Lifecycle

extension PinScreen {

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

/// :nodoc:
private extension PinScreen {

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
		let doneButton = UIBarButtonItem(title: L10n.Pin.done,
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
		oldPinField.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.keyboardType = .numberPad
			$0.inputAccessoryView = keyboardToolbar
			$0.superview?.isHidden = presenter.getOperation() != .credentialChange
		}
	}

	func setupPinField() {
		pinField.do {
			addItem($0, topSpacing: 16)
			$0.setHeight(with: 40)
			$0.keyboardType = .numberPad
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
		if let superview = oldPinField.superview, !superview.isHidden {
			oldPinField.becomeFirstResponder()
		}
		else {
			pinField.becomeFirstResponder()
		}
	}
}

// MARK: - PinView

/// :nodoc:
extension PinScreen: PinView {

	func update(by protectionInfo: PinProtectionInformation) {
		infoMessageLabel.text = protectionInfo.message
		confirmButton.isEnabled = !protectionInfo.isInCoolDown
		cancelButton.isEnabled = !protectionInfo.isInCoolDown
	}
}

// MARK: - Actions

/// :nodoc:
private extension PinScreen {

	@objc
	func done() {
		view.endEditing(true)
	}

	@objc
	func confirm() {
		if presenter.getOperation() == .credentialChange, oldPinField.text.isEmptyOrNil {
			errorLabel.text = L10n.Pin.missingOldPin
			return
		}

		guard let pin = pinField.text, !pin.isEmpty else {
			errorLabel.text = L10n.Pin.missingPin
			return
		}

		errorLabel.text = nil
		presenter.confirm(oldPin: oldPinField.text ?? String(), pin: pin)
	}

	@objc
	func cancel() {
		presenter.cancel()
	}
}
