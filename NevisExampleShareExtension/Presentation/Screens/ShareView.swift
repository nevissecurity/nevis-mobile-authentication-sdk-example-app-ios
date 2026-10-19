//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

/// The screen of the share extension: account list, status, credential entry and verification buttons.
struct ShareView: View {
	// MARK: - Properties

	/// The model driving the screen.
	@ObservedObject var model: ShareModel
	/// Whether the credential field is focused.
	@FocusState private var isCredentialFocused: Bool
	/// The scroll target identifier of the credential card.
	private let credentialCardId = "credentialCard"

	// MARK: - Body

	/// The content of the screen.
	var body: some View {
		GeometryReader { geometry in
			ScrollViewReader { scrollProxy in
				ScrollView {
					VStack(spacing: 16) {
						Text(L10n.Share.title)
							.font(.title2.bold())

						if model.accounts.isEmpty {
							noAccountsCard
						} else {
							accountList(model.accounts)
						}

						if case let .awaitingCredential(prompt, coolDownEnd) = model.status {
							Group {
								if let coolDownEnd {
									TimelineView(.periodic(from: .now, by: 1)) { context in
										let remaining = max(0, Int(ceil(coolDownEnd.timeIntervalSince(context.date))))
										credentialCard(prompt: prompt, cooldownRemaining: remaining)
									}
								} else {
									credentialCard(prompt: prompt, cooldownRemaining: 0)
								}
							}
							.id(credentialCardId)
						}

						if case .awaitingCredential = model.status {} else { statusCard }

						Spacer(minLength: 0)

						if let account = model.selectedAccount {
							if account.authenticators.isEmpty {
								noAuthenticatorsCard(username: account.username)
							} else {
								VStack(spacing: 16) {
									ForEach(account.authenticators) { authenticator in
										let title = L10n.Share.verify(authenticator.localizedTitle)
										OutlinedButton(title: title, icon: .authenticator(authenticator)) {
											Task { await model.verify(authenticator) }
										}
									}
								}
								.disabled(model.isBusy)
							}
						}

						OutlinedButton(title: L10n.Share.done, action: model.done)
					}
					.padding(16)
					.frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
				}
				.dismissesKeyboardInteractively()
				.onChange(of: isCredentialFocused) { focused in
					guard focused else { return }

					DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
						withAnimation { scrollProxy.scrollTo(credentialCardId, anchor: .bottom) }
					}
				}
			}
		}
		.background(
			Color(.systemGroupedBackground)
				.ignoresSafeArea()
				.onTapGesture { isCredentialFocused = false }
		)
		.task(id: model.status) {
			guard case let .awaitingCredential(_, coolDownEnd) = model.status else { return }
			if let end = coolDownEnd {
				let remaining = max(0, end.timeIntervalSinceNow)
				try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
			}
			guard !Task.isCancelled else { return }
			isCredentialFocused = true
		}
		.task { await model.start() }
	}
}

// MARK: - Private Interface

private extension ShareView {
	/// Shown when the containing app has no registered accounts.
	@ViewBuilder
	var noAccountsCard: some View {
		InfoCard(
			icon: .warning,
			tint: .yellow,
			title: L10n.Share.noAccountsTitle,
			message: L10n.Share.noAccountsMessage
		)
	}

	/// The selectable list of accounts.
	///
	/// - Parameter accounts: The accounts to list.
	/// - Returns: The account list.
	@ViewBuilder
	func accountList(_ accounts: [RegisteredAccount]) -> some View {
		SingleSelectionList(
			title: L10n.Share.accounts,
			items: accounts,
			selectedItem: $model.selectedAccount
		) { item in
			HStack {
				Text(item.username)
				Spacer()
			}
		}
		.disabled(model.isBusy)
	}

	/// The credential entry card.
	///
	/// - Parameters:
	///   - prompt: The pending credential prompt.
	///   - cooldownRemaining: Seconds until input is allowed again.
	/// - Returns: The credential card.
	@ViewBuilder
	func credentialCard(prompt: CredentialPrompt, cooldownRemaining: Int) -> some View {
		CredentialCard(
			icon: model.status.icon,
			tint: model.status.tint,
			title: model.status.title,
			prompt: prompt,
			cooldownRemaining: cooldownRemaining,
			isFocused: $isCredentialFocused,
			submit: model.submitCredential,
			cancel: model.cancelCredential
		)
	}

	/// The card showing the current ``Status``.
	@ViewBuilder
	var statusCard: some View {
		InfoCard(
			icon: model.status.icon,
			tint: model.status.tint,
			title: model.status.title,
			message: model.status.message,
			spinning: model.status == .initializing,
			extraContent: {
				if case .lockedOut(_, _) = model.status {
					deleteButton
				}
			}
		)
	}

	/// Deletes the locked out authenticator; shown in the ``statusCard`` on ``Status/lockedOut(username:authenticator:)``.
	@ViewBuilder
	var deleteButton: some View {
		Button(
			role: .destructive,
			action: {
				Task { await model.deleteLockedRegistration() }
			}
		) {
			Label(L10n.Share.delete, systemImage: Icon.trash.systemName)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 16)
		}
		.buttonStyle(.borderedProminent)
	}

	/// Shown instead of the buttons when the selected account has no usable authenticator.
	///
	/// - Parameter username: The username of the selected account.
	/// - Returns: The info card.
	@ViewBuilder
	func noAuthenticatorsCard(username: String) -> some View {
		InfoCard(
			icon: .warning,
			tint: .yellow,
			title: L10n.Share.noAuthenticatorsTitle,
			message: L10n.Share.noAuthenticatorsMessage(username)
		)
	}
}
