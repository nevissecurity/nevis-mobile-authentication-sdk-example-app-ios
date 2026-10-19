//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Combine
import Foundation
import NevisExampleShared
import NevisMobileAuthentication

/// Drives ``ShareView``: initializes the SDK, lists the accounts and runs the authentications.
@MainActor
final class ShareModel: ObservableObject {
	// MARK: - Properties

	/// The current state of the flow.
	@Published private(set) var status: Status = .initializing
	/// The accounts registered in the containing app.
	@Published private(set) var accounts = [RegisteredAccount]()
	/// The account to authenticate; selected in the account list.
	@Published var selectedAccount: RegisteredAccount?

	/// Initializes the SDK, provides the accounts and runs the authentications.
	private let authenticationService: AuthenticationService
	/// Called when the user is done. The hosting controller completes the extension request.
	var onDone: (() -> ())?
	/// Whether an authentication or deletion is in progress. The account list and the buttons are disabled meanwhile.
	var isBusy: Bool {
		switch status {
			case .authenticating, .awaitingCredential, .deleting: true
			default: false
		}
	}

	/// Resumes the pending ``requestCredential(_:)`` with the entered credential, or `nil` on cancel.
	private var credentialContinuation: CheckedContinuation<String?, Never>?

	// MARK: - Initialization

	/// Creates the model.
	///
	/// - Parameter authenticationService: The service running the SDK operations.
	init(authenticationService: AuthenticationService) {
		self.authenticationService = authenticationService
	}

	// MARK: - Public Interface

	/// Loads the configuration, initializes the SDK client and loads the accounts. No-op if already started.
	func start() async {
		guard case .initializing = status else {
			return
		}

		do {
			try await authenticationService.initialize()
			self.refreshAccounts()
		} catch {
			status = .failed(cause: error.localizedDescription)
		}
	}

	/// Cancels the pending credential request and ends the flow by calling ``onDone``.
	func done() {
		cancelCredential()
		onDone?()
	}

	/// Authenticates the selected account with the given authenticator.
	///
	/// - Parameter authenticator: The authenticator to use.
	func verify(_ authenticator: AuthenticatorKind) async {
		guard !isBusy else {
			return
		}

		guard let username = selectedAccount?.username else {
			status = .failed(cause: ExtensionError.accountNotFound.localizedDescription)
			return
		}

		status = .authenticating(username: username)
		// The authentication can end, e.g. with a timeout, while a credential request is still pending.
		defer { cancelCredential() }

		do {
			let jwt = try await authenticationService.authenticate(username, using: authenticator) { [weak self] prompt in
				await self?.requestCredential(prompt)
			}
			self.status = .authenticated(username: username, jwt: jwt)
		} catch let HeadlessAuthenticationError.lockedOut(authenticator) {
			status = .lockedOut(username: username, authenticator: authenticator)
		} catch HeadlessAuthenticationError.cancelled {
			status = .ready
		} catch AuthenticationServiceError.notInitialized {
			status = .failed(cause: ExtensionError.notInitialized.localizedDescription)
		} catch {
			status = .failed(cause: error.localizedDescription)
		}

		self.refreshAccounts()
	}

	/// Submits `credential` to the pending credential request and returns to ``Status/authenticating(username:)``.
	///
	/// - Parameter credential: The credential entered by the user.
	func submitCredential(_ credential: String) {
		credentialContinuation?.resume(returning: credential)
		credentialContinuation = nil
		if case let .awaitingCredential(prompt, _) = status {
			status = .authenticating(username: prompt.username)
		}
	}

	/// Cancels the pending credential request; the authentication ends with ``Status/ready``.
	func cancelCredential() {
		credentialContinuation?.resume(returning: nil)
		credentialContinuation = nil
	}

	/// Deletes the locked out authenticator from the device and reloads the accounts. No-op unless the status is
	/// ``Status/lockedOut(username:authenticator:)``.
	func deleteLockedRegistration() async {
		guard case let .lockedOut(username, authenticator) = status else {
			return
		}

		status = .deleting(username: username, authenticator: authenticator)
		do {
			try await authenticationService.delete(username: username, authenticator: authenticator)
			status = .ready
		} catch {
			status = .failed(cause: error.localizedDescription)
		}

		self.refreshAccounts()
	}
}

// MARK: - Private Interface

private extension ShareModel {
	/// Reloads the accounts and their usable methods, keeping the selection if the account still exists.
	func refreshAccounts() {
		accounts = authenticationService.accounts()
		selectedAccount = accounts.first { $0.id == selectedAccount?.id } ?? accounts.first

		if status == .initializing {
			status = .ready
		}
	}

	/// Shows the credential card and waits until the user submits or cancels.
	///
	/// - Parameter prompt: The credential prompt from the SDK.
	/// - Returns: The entered credential, or `nil` if cancelled.
	func requestCredential(_ prompt: CredentialPrompt) async -> String? {
		status = .awaitingCredential(prompt: prompt, coolDownEnd: prompt.coolDownEnd())
		return await withCheckedContinuation { credentialContinuation = $0 }
	}
}
