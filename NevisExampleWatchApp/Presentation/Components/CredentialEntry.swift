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

	/// Called with the entered credential.
	let submit: (String) -> ()

	/// The entered credential.
	@State private var credential = ""

	/// The end of the cool down. `nil` if input is allowed.
	@State private var coolDownEnd: Date?

	// MARK: - Initialization

	/// Creates a new instance. The cool down starts when the view is created, i.e. when the prompt is received.
	///
	/// - Parameters:
	///   - prompt: The credential request.
	///   - submit: Called with the entered credential.
	init(prompt: CredentialPrompt, submit: @escaping (String) -> ()) {
		self.prompt = prompt
		self.submit = submit
		_coolDownEnd = State(initialValue: prompt.coolDownEnd())
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
				if let coolDownEnd {
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
		.task {
			await waitForCoolDown()
		}
	}
}

// MARK: - Private Interface

private extension CredentialEntry {
	/// Whether input is not allowed yet.
	var isCoolingDown: Bool {
		coolDownEnd != nil
	}

	/// Enables the entry when the cool down ends.
	func waitForCoolDown() async {
		guard let coolDownEnd else {
			return
		}

		try? await Task.sleep(for: .seconds(coolDownEnd.timeIntervalSinceNow))
		guard !Task.isCancelled else {
			return
		}

		self.coolDownEnd = nil
	}

	/// Submits the credential if it is not empty.
	func submitIfEntered() {
		guard !credential.isEmpty, !isCoolingDown else {
			return
		}

		submit(credential)
	}
}
