//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Not Enrolled Authenticator view.
final class NotEnrolledAuthenticatorScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The content view.
	private let contentView = UIStackView(frame: .zero)

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.NotEnrolledAuthenticator.title, style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(text: L10n.NotEnrolledAuthenticator.description, style: .normal, textAlignment: .center)

	/// The action button.
	private let actionButton = OutlinedButton(title: L10n.NotEnrolledAuthenticator.action)

	// MARK: - Properties

	/// The presenter.
	var presenter: NotEnrolledAuthenticatorPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: NotEnrolledAuthenticatorPresenter) {
		super.init()
		self.presenter = presenter
	}
}

// MARK: - Lifecycle

extension NotEnrolledAuthenticatorScreen {

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
private extension NotEnrolledAuthenticatorScreen {

	func setupUI() {
		setupContentView()
		setupTitleLabel()
		setupDescriptionLabel()
		setupActionButton()
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
		}
	}

	func setupDescriptionLabel() {
		descriptionLabel.do {
			contentView.addArrangedSubview($0)
		}
	}

	func setupActionButton() {
		actionButton.do {
			addItemToBottom($0, spacing: 16)
			$0.setHeight(with: 40)
			$0.addTarget(self, action: #selector(doAction), for: .touchUpInside)
		}
	}
}

// MARK: - Actions

/// :nodoc:
private extension NotEnrolledAuthenticatorScreen {
	@objc
	func doAction() {
		presenter.doAction()
	}
}
