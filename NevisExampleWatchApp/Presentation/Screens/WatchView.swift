//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

/// The screen of the watch app.
struct WatchView: View {
	// MARK: - Properties

	/// The model driving the screen.
	let model: WatchModel

	/// The scene phase. Used to refresh the accounts when the app becomes active.
	@Environment(\.scenePhase) private var scenePhase

	// MARK: - Body

	var body: some View {
		NavigationStack {
			content
				.navigationTitle(Text(.watchTitle))
		}
		.sheet(isPresented: isAuthenticationPresented) {
			AuthenticationView(model: model)
		}
		.task { await model.observeReachability() }
		.task { await model.observeMessages() }
		.onChange(of: scenePhase, initial: true) { _, phase in
			if phase == .active {
				Task { await model.loadAccounts() }
			}
		}
	}
}

// MARK: - Private Interface

private extension WatchView {
	/// Presents the authentication while there is one. Closing the sheet closes (and cancels) the authentication.
	var isAuthenticationPresented: Binding<Bool> {
		Binding {
			model.authentication != nil
		} set: { isPresented in
			if !isPresented {
				Task { await model.closeAuthentication() }
			}
		}
	}

	/// The content matching the state.
	@ViewBuilder
	private var content: some View {
		switch model.state {
			case .loading:
				ProgressView()
			case let .accounts(accounts) where accounts.isEmpty:
				MessageView(
					systemImage: Icon.noAccount.systemName,
					title: String(localized: .noAccountsTitle),
					message: String(localized: .noAccountsMessage)
				) {
					Task { await model.loadAccounts() }
				}
			case let .accounts(accounts):
				List {
					Section {
						ForEach(accounts) { account in
							Button {
								model.select(account)
							} label: {
								AccountRow(account: account, isSelected: account.username == model.selectedUsername)
							}
						}
					} header: {
						Text(.accountsTitle)
					}
					if let account = model.selectedAccount {
						Section {
							ForEach(account.authenticators) { authenticator in
								Button {
									Task { await model.authenticate(account, with: authenticator) }
								} label: {
									Label {
										Text(authenticator.localizedTitle)
									} icon: {
										Image(systemName: authenticator.systemImage)
									}
								}
							}
						} header: {
							Text(.authenticatorsTitle)
						}
					}
				}
			case let .failed(error):
				MessageView(
					systemImage: Icon.error.systemName,
					title: String(localized: .errorTitle),
					message: error.localizedDescription
				) {
					Task { await model.loadAccounts() }
				}
		}
	}
}
