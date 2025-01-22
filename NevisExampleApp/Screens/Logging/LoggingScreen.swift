//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import UIKit

/// The Logging view. Displays SDK related logging events.
final class LoggingScreen: UIViewController, Screen {

	// MARK: - UI

	/// The separator.
	private let separator = UIView(frame: .zero)

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.Logging.title, style: .normal)

	/// The text view displaying the logs.
	private let logView = UITextView(frame: .zero)

	// MARK: - Properties

	/// The presenter.
	var presenter: LoggingPresenter!

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: LoggingPresenter) {
		super.init(nibName: nil, bundle: nil)
		self.presenter = presenter
		self.presenter.view = self
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		logger.deinit("LoggingScreen")
	}
}

// MARK: - Lifecycle

extension LoggingScreen {

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

private extension LoggingScreen {

	func setupUI() {
		setupSeperator()
		setupTitleLabel()
		setupLogView()
	}

	func setupSeperator() {
		separator.do {
			view.addSubview($0)
			$0.anchorToTop(0)
			$0.anchorToLeft()
			$0.anchorToRight()
			$0.setHeight(with: 2)
			$0.backgroundColor = .black
		}
	}

	func setupTitleLabel() {
		titleLabel.do {
			view.addSubview($0)
			$0.anchorToTop(10, toSafeLayout: true)
			$0.anchorToLeft(10)
			$0.anchorToRight(10)
		}
	}

	func setupLogView() {
		logView.do {
			view.addSubview($0)
			$0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
			$0.anchorToLeft(10)
			$0.anchorToRight(10)
			$0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).do {
				$0.priority = .defaultLow
				$0.isActive = true
			}
		}
	}
}

// MARK: - LoggingView

extension LoggingScreen: LoggingView {
	func update(by message: NSAttributedString) {
		let attributedText = NSMutableAttributedString(attributedString: logView.attributedText)
		attributedText.append(NSAttributedString(attributedString: message))
		logView.attributedText = attributedText
	}
}
