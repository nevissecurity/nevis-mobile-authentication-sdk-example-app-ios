//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

/// Shows the progress and the result of an authentication running on the iPhone.
struct AuthenticationView: View {
	// MARK: - Properties

	/// The model driving the authentication.
	let model: WatchModel

	// MARK: - Body

	var body: some View {
		NavigationStack {
			content
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button(role: .cancel) {
							Task { await model.closeAuthentication() }
						} label: {
							Label {
								Text(.close)
							} icon: {
								Image(systemName: Icon.close.systemName)
							}
						}
					}
				}
		}
	}
}

// MARK: - Private Interface

private extension AuthenticationView {
	/// The content matching the state of the authentication.
	@ViewBuilder
	var content: some View {
		switch model.authentication {
			case .waitingForPhone, nil:
				ProgressView {
					Text(.waitingForPhone)
				}
			case let .credentialRequired(prompt):
				CredentialEntry(prompt: prompt) { credential in
					Task { await model.submit(credential) }
				}
			case let .continueOnPhone(authenticator):
				MessageView(
					systemImage: authenticator.systemImage,
					title: String(localized: .continueOnPhoneTitle),
					message: String(localized: .continueOnPhoneMessage)
				)
			case let .succeeded(username):
				MessageView(
					systemImage: Icon.success.systemName,
					title: String(localized: .authenticatedTitle),
					message: username
				)
			case let .failed(error):
				MessageView(
					systemImage: Icon.error.systemName,
					title: String(localized: .authenticationFailedTitle),
					message: error.localizedDescription
				)
		}
	}
}
