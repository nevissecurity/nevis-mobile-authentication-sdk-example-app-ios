//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Result view.
final class ResultScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The content view.
	private let contentView = UIStackView(frame: .zero)

	/// The title label.
	private let titleLabel = NSLabel(style: .title)

	/// The description label.
	private let descriptionLabel = NSLabel(style: .normal, textAlignment: .center)

	/// The action button.
	private let actionButton = OutlinedButton(title: L10n.Result.continue)

	// MARK: - Properties

	/// The presenter.
	var presenter: ResultPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: ResultPresenter) {
		super.init()
		self.presenter = presenter
	}

	deinit {
		logger.deinit("ResultScreen")
	}
}

// MARK: - Lifecycle

extension ResultScreen {

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

private extension ResultScreen {

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
			$0.text = presenter.getTitle()
		}
	}

	func setupDescriptionLabel() {
		descriptionLabel.do {
			contentView.addArrangedSubview($0)
			$0.text = presenter.getDescription()
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

private extension ResultScreen {
	@objc
	func doAction() {
		presenter.doAction()
	}
}
