//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

/// A card for entering the credential, showing the protection status and the cooldown.
struct CredentialCard: View {
	// MARK: - Properties

	/// The credential entered so far.
	@State private var credentialInput = ""
	/// The icon shown before the title.
	let icon: Icon
	/// The color of the icon.
	let tint: Color
	/// The title of the card.
	let title: String
	/// The prompt providing the credential kind and the hint.
	let prompt: CredentialPrompt
	/// Seconds until the credential can be entered again. Input is disabled while greater than 0.
	let cooldownRemaining: Int
	/// Focus of the credential field, owned by the parent so it can scroll and dismiss the keyboard.
	let isFocused: FocusState<Bool>.Binding
	/// Called with the entered credential.
	let submit: (String) -> ()
	/// Called when the user cancels the credential entry.
	let cancel: () -> ()

	// MARK: - View

	/// The content of the card.
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			CardHeader(icon: icon, tint: tint, title: title)

			if !prompt.hint.isEmpty {
				Text(prompt.hint)
					.font(.footnote)
					.foregroundStyle(.orange)
			}

			SecureField(prompt.kind.authenticator.localizedTitle, text: $credentialInput)
				.keyboardType(prompt.kind.keyboardType)
				.textContentType(prompt.kind.textContentType)
				.textFieldStyle(.roundedBorder)
				.focused(isFocused)
				.submitLabel(.go)
				.disabled(cooldownRemaining > 0)
				.onSubmit {
					if cooldownRemaining == 0 && !credentialInput.isEmpty {
						submitAction()
					}
				}

			if cooldownRemaining > 0 {
				Label(L10n.CredentialCard.tryAgain(cooldownRemaining), systemImage: Icon.cooldown.systemName)
					.font(.footnote)
					.foregroundStyle(.secondary)
			}

			HStack(spacing: 8) {
				Button(L10n.CredentialCard.submit, action: submitAction)
					.buttonStyle(.borderedProminent)
					.disabled(cooldownRemaining > 0 || credentialInput.isEmpty)

				Button(L10n.CredentialCard.cancel) {
					credentialInput = ""
					isFocused.wrappedValue = false
					cancel()
				}
				.foregroundStyle(.secondary)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.cardStyle()
	}
}

// MARK: - Private Interface

private extension CredentialCard {
	/// Clears the field, dismisses the keyboard and submits the entered credential.
	func submitAction() {
		let credential = credentialInput
		credentialInput = ""
		isFocused.wrappedValue = false
		submit(credential)
	}
}
