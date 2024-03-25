//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import UIKit

/// The Confirmation view.
final class ConfirmationScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The content view.
	private let contentView = UIStackView(frame: .zero)

	/// The title label.
	private let titleLabel = NSLabel(style: .title)

	/// The confirm button.
	private let confirmButton = OutlinedButton(title: L10n.Confirmation.confirm)

	/// The cancel button.
	private let cancelButton = OutlinedButton(title: L10n.Confirmation.cancel)

	// MARK: - Properties

	/// The presenter.
	var presenter: ConfirmationPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: ConfirmationPresenter) {
		super.init()
		self.presenter = presenter
	}

	/// :nodoc:
	deinit {
		os_log("ConfirmationScreen", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Lifecycle

extension ConfirmationScreen {

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
private extension ConfirmationScreen {

	func setupUI() {
		setupContentView()
		setupTitleLabel()
		setupConfirmButton()
		setupCancelButton()
	}

	func setupContentView() {
		contentView.do {
			view.addSubview($0)
			$0.anchorToMiddle()
			$0.anchorToLeft(16)
			$0.anchorToRight(16)
			$0.spacing = 16
			$0.axis = .vertical
		}
	}

	func setupTitleLabel() {
		titleLabel.do {
			contentView.addArrangedSubview($0)
			$0.text = presenter.getTitle()
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

/// :nodoc:
private extension ConfirmationScreen {
	@objc
	func confirm() {
		presenter.confirm()
	}

	@objc
	func cancel() {
		presenter.cancel()
	}
}
