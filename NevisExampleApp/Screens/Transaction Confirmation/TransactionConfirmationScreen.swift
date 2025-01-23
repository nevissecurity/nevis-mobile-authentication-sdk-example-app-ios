//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Transaction Confirmation view.
final class TransactionConfirmationScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.TrxConfirm.title, style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(style: .normal)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.TrxConfirm.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.TrxConfirm.cancel)

	// MARK: - Properties

	/// The presenter.
	var presenter: TransactionConfirmationPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: TransactionConfirmationPresenter) {
		super.init()
		self.presenter = presenter
	}

	deinit {
		logger.deinit("TransactionConfirmationScreen")
	}
}

// MARK: - Lifecycle

extension TransactionConfirmationScreen {

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

private extension TransactionConfirmationScreen {

	func setupUI() {
		setupTitleLabel()
		setupDescriptionLabel()
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
			$0.text = presenter.getMessage()
		}
	}

	func setupConfirmButton() {
		confirmButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
		}
	}

	func setupCancelButton() {
		cancelButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		}
	}
}

// MARK: - Actions

private extension TransactionConfirmationScreen {
	@objc
	func confirm() {
		presenter.confirm()
	}

	@objc
	func cancel() {
		presenter.cancel()
	}
}
