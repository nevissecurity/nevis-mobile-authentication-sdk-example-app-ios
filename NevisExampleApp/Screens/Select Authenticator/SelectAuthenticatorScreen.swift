//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// The Authenticator Selection view. Shows the list of available authenticators.
final class SelectAuthenticatorScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.AuthenticatorSelection.title, style: .title)

	/// The table view.
	private let tableView = UITableView(frame: .zero, style: .grouped)

	// MARK: - Properties

	/// The presenter.
	var presenter: SelectAuthenticatorPresenter!

	/// The list of authenticator items.
	private var authenticatorItems = [AuthenticatorItem]()

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: SelectAuthenticatorPresenter) {
		super.init()
		self.presenter = presenter
	}

	/// :nodoc:
	deinit {
		os_log("SelectAuthenticatorScreen", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Lifecycle

extension SelectAuthenticatorScreen {

	/// Override of the `viewDidLoad()` lifecycle method. Sets up the user interface.
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	/// Override of the `viewWillAppear(_:)` lifecycle method.
	///
	/// - parameter animated: If *true*, the view is being added to the window using an animation.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		authenticatorItems = presenter.getAuthenticators()
		tableView.reloadData()
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

/// :nodoc:
private extension SelectAuthenticatorScreen {

	func setupUI() {
		setupTitleLabel()
		setupTableView()
	}

	func setupTitleLabel() {
		titleLabel.do {
			addItemToTop($0, spacing: 10, topSpacing: 32)
		}
	}

	func setupTableView() {
		tableView.do {
			view.addSubview($0)
			$0.topAnchor.constraint(equalTo: topStackView.bottomAnchor).isActive = true
			$0.anchorToLeft()
			$0.anchorToRight()
			$0.anchorToBottom(16)
			$0.backgroundColor = .clear
			$0.rowHeight = UITableView.automaticDimension
			$0.register(AuthenticatorCell.self, forCellReuseIdentifier: AuthenticatorCell.reuseIdentifier)
			$0.dataSource = self
			$0.delegate = self
		}
	}
}

// MARK: - UITableViewDataSource

/// :nodoc:
extension SelectAuthenticatorScreen: UITableViewDataSource {
	func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		authenticatorItems.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: AuthenticatorCell.reuseIdentifier, for: indexPath) as? AuthenticatorCell else {
			fatalError(
				"Failed to dequeue a cell with identifier \(AuthenticatorCell.reuseIdentifier) matching type \(AuthenticatorCell.self)."
			)
		}
		let idx = authenticatorItems.index(authenticatorItems.startIndex, offsetBy: indexPath.row)
		let item = authenticatorItems[idx]
		var details: String? {
			guard !item.isEnabled else {
				return nil
			}

			if !item.isPolicyCompliant {
				return L10n.AuthenticatorSelection.authenticatorNotPolicyCompliant
			}
			if !item.isUserEnrolled {
				return L10n.AuthenticatorSelection.authenticatorNotEnrolled
			}

			return nil
		}
		cell.bind(viewModel: .init(title: item.authenticator.localizedTitle,
		                           isEnabled: item.isEnabled,
		                           details: details))
		return cell
	}
}

// MARK: - UITableViewDelegate

/// :nodoc:
extension SelectAuthenticatorScreen: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let idx = authenticatorItems.index(authenticatorItems.startIndex, offsetBy: indexPath.row)
		let item = authenticatorItems[idx]
		guard item.isEnabled else {
			return
		}

		let authenticator = authenticatorItems[idx].authenticator
		presenter.select(authenticator: authenticator)
	}
}
