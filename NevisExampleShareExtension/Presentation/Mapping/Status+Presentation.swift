//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

extension Status {
	/// The icon of the status card.
	var icon: Icon {
		switch self {
			case .initializing:
				Icon.initializing
			case .authenticating:
				Icon.authenticating
			case let .awaitingCredential(prompt, _):
				.authenticator(prompt.kind.authenticator)
			case .deleting:
				Icon.trash
			case .authenticated:
				Icon.authenticated
			case .lockedOut:
				Icon.lockedOut
			case .ready:
				Icon.success
			case .failed:
				Icon.error
		}
	}

	/// The color of the status card's icon.
	var tint: Color {
		switch self {
			case .initializing, .authenticating, .awaitingCredential:
				.blue
			case .authenticated, .ready:
				.green
			case .deleting, .lockedOut, .failed:
				.red
		}
	}

	/// The title of the status card.
	var title: String {
		switch self {
			case .initializing:
				L10n.Status.Title.initializing
			case .authenticating:
				L10n.Status.Title.authenticating
			case let .awaitingCredential(prompt, _):
				prompt.kind.localizedPromptTitle
			case .deleting:
				L10n.Status.Title.deleting
			case .authenticated:
				L10n.Status.Title.authenticated
			case .ready:
				L10n.Status.Title.ready
			case .lockedOut:
				L10n.Status.Title.lockedOut
			case .failed:
				L10n.Status.Title.failed
		}
	}

	/// The message of the status card.
	var message: String {
		switch self {
			case .initializing:
				L10n.Status.Message.initializing
			case let .authenticating(username):
				L10n.Status.Message.authenticating(username)
			case let .awaitingCredential(prompt, _):
				L10n.Status.Message.awaitingCredential(prompt.username)
			case let .deleting(username, authenticator):
				L10n.Status.Message.deleting(username, authenticator.localizedTitle)
			case let .authenticated(username, jwt):
				L10n.Status.Message.authenticated(username, jwt ?? "N/A")
			case .ready:
				L10n.Status.Message.ready
			case .lockedOut:
				L10n.Status.Message.lockedOut
			case let .failed(cause):
				cause
		}
	}
}
