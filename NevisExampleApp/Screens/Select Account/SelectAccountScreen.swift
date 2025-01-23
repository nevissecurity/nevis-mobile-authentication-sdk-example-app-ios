//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import UIKit

/// The Account Selection view. Shows the list of available accounts.
final class SelectAccountScreen: BaseScreen, Screen {

	// MARK: - UI

	/// The title label.
	private let titleLabel = NSLabel(text: L10n.AccountSelection.title, style: .title)

	/// The table view.
	private let tableView = UITableView(frame: .zero, style: .grouped)

	// MARK: - Properties

	/// The presenter.
	var presenter: SelectAccountPresenter!

	/// The list of accounts.
	private var accounts = [any Account]()

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter presenter: The presenter.
	init(presenter: SelectAccountPresenter) {
		super.init()
		self.presenter = presenter
		self.presenter.view = self
	}

	deinit {
		logger.deinit("SelectAccountScreen")
	}
}

// MARK: - Lifecycle

extension SelectAccountScreen {

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
		accounts = presenter.getAccounts()
		tableView.reloadData()
	}

	func refresh() {
		// do nothing
	}
}

// MARK: - Setups

private extension SelectAccountScreen {

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
			$0.register(AccountCell.self, forCellReuseIdentifier: AccountCell.reuseIdentifier)
			$0.dataSource = self
			$0.delegate = self
		}
	}
}

// MARK: - UITableViewDataSource

extension SelectAccountScreen: UITableViewDataSource {
	func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		accounts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseIdentifier, for: indexPath) as? AccountCell else {
			fatalError(
				"Failed to dequeue a cell with identifier \(AccountCell.reuseIdentifier) matching type \(AccountCell.self)."
			)
		}
		let idx = accounts.index(accounts.startIndex, offsetBy: indexPath.row)
		let account = accounts[idx]
		cell.bind(viewModel: .init(title: account.username))
		return cell
	}
}

// MARK: - UITableViewDelegate

extension SelectAccountScreen: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let idx = accounts.index(accounts.startIndex, offsetBy: indexPath.row)
		let account = accounts[idx]
		presenter.select(account: account)
	}
}
