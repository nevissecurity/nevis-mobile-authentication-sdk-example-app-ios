//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import SwiftUI

/// Entry of the PIN or password requested by the iPhone.
///
/// While the authenticator is cooling down after a failed attempt the entry is disabled and the remaining time is shown.
struct CredentialEntry: View {
	// MARK: - Properties

	/// The credential request.
	let prompt: CredentialPrompt

	/// When input is allowed again. `nil` if there is no cool down.
	let coolDownEnd: Date?

	/// Called with the entered credential.
	let submit: (String) -> ()

	/// The entered credential.
	@State private var credential = ""

	/// Whether input is not allowed yet.
	@State private var isCoolingDown: Bool

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - prompt: The credential request.
	///   - coolDownEnd: When input is allowed again. `nil` if there is no cool down.
	///   - submit: Called with the entered credential.
	init(prompt: CredentialPrompt, coolDownEnd: Date?, submit: @escaping (String) -> ()) {
		self.prompt = prompt
		self.coolDownEnd = coolDownEnd
		self.submit = submit
		_isCoolingDown = State(initialValue: coolDownEnd.map { $0 > .now } ?? false)
	}

	// MARK: - View

	/// The content of the view.
	var body: some View {
		ScrollView {
			VStack(spacing: 8) {
				Text(prompt.kind.localizedPromptTitle)
					.font(.headline)
				Text(prompt.username)
					.font(.footnote)
					.foregroundStyle(.secondary)
					.lineLimit(1)
				if !prompt.hint.isEmpty {
					Text(prompt.hint)
						.font(.footnote)
						.foregroundStyle(.orange)
				}
				if let coolDownEnd, isCoolingDown {
					Label {
						Text(timerInterval: min(Date.now, coolDownEnd) ... coolDownEnd, countsDown: true)
							.monospacedDigit()
					} icon: {
						Image(systemName: Icon.coolDown.systemName)
					}
					.font(.title3)
				}
				SecureField(prompt.kind.localizedPromptTitle, text: $credential)
					.onSubmit(submitIfEntered)
					.disabled(isCoolingDown)
				Button(action: submitIfEntered) {
					Text(.submit)
				}
				.disabled(credential.isEmpty || isCoolingDown)
			}
		}
		.task(id: coolDownEnd) {
			await waitForCoolDown()
		}
	}
}

// MARK: - Private Interface

private extension CredentialEntry {
	/// Disables the entry until the cool down ends.
	func waitForCoolDown() async {
		guard let coolDownEnd, coolDownEnd > .now else {
			isCoolingDown = false
			return
		}

		isCoolingDown = true
		try? await Task.sleep(for: .seconds(coolDownEnd.timeIntervalSinceNow))
		guard !Task.isCancelled else {
			return
		}

		isCoolingDown = false
	}

	/// Submits the credential if it is not empty.
	func submitIfEntered() {
		guard !credential.isEmpty, !isCoolingDown else {
			return
		}

		submit(credential)
	}
}
