//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import Observation

/// The model of ``WatchView``.
@Observable
final class WatchModel {
	// MARK: - Properties

	/// The state of the screen.
	private(set) var state = WatchState.loading

	/// The username of the selected account. `nil` if there are no accounts.
	private(set) var selectedUsername: String?

	/// The ongoing or just finished authentication. `nil` if there is none.
	private(set) var authentication: AuthenticationState?

	/// The selected account.
	var selectedAccount: RegisteredAccount? {
		guard case let .accounts(accounts) = state else {
			return nil
		}

		return accounts.first { $0.username == selectedUsername }
	}

	/// The session with the iPhone app.
	@ObservationIgnored private let session: PhoneSession

	/// Whether the accounts are being loaded.
	@ObservationIgnored private var isLoading = false

	/// The authenticator of the ongoing authentication.
	@ObservationIgnored private var authenticator: AuthenticatorKind?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter session: The session with the iPhone app.
	init(session: PhoneSession) {
		self.session = session
	}

	// MARK: - Public Interface

	/// Loads the registered accounts from the iPhone app. Ignored while a load is in progress.
	func loadAccounts() async {
		guard !isLoading else {
			return
		}

		isLoading = true
		defer { isLoading = false }

		if case .failed = state {
			state = .loading
		}

		do throws(WatchError) {
			switch try await session.send(.accounts) {
				case let .accounts(accounts):
					state = .accounts(accounts)
					if !accounts.contains(where: { $0.username == selectedUsername }) {
						selectedUsername = accounts.first?.username
					}
				case let .failed(error):
					state = .failed(error)
				default:
					state = .failed(.invalidMessage)
			}
		} catch {
			state = .failed(error)
		}
	}

	/// Reloads the accounts whenever the iPhone app becomes reachable after a failure. Runs until cancelled.
	func observeReachability() async {
		for await isReachable in session.reachabilityUpdates where isReachable {
			if case .failed = state {
				await loadAccounts()
			}
		}
	}

	/// Emits the messages pushed by the iPhone app to the ongoing authentication. Runs until cancelled.
	func observeMessages() async {
		for await message in session.messages {
			handle(message)
		}
	}

	/// Selects an account.
	///
	/// - Parameter account: The account to select.
	func select(_ account: RegisteredAccount) {
		selectedUsername = account.username
	}

	/// Starts an authentication on the iPhone. Ignored while another authentication is shown.
	///
	/// - Parameters:
	///   - account: The account to authenticate.
	///   - authenticator: The authenticator to use.
	func authenticate(_ account: RegisteredAccount, with authenticator: AuthenticatorKind) async {
		guard authentication == nil else {
			return
		}

		self.authenticator = authenticator
		authentication = .waitingForPhone
		await send(.authenticate(username: account.username, authenticator: authenticator))
	}

	/// Sends the PIN or password requested by the iPhone.
	///
	/// - Parameter credential: The entered credential.
	func submit(_ credential: String) async {
		guard case .credentialRequired = authentication else {
			return
		}

		authentication = .waitingForPhone
		await send(.credential(credential))
	}

	/// Closes the authentication. Cancels it on the iPhone if it is still in progress.
	func closeAuthentication() async {
		guard let authentication else {
			return
		}

		self.authentication = nil
		if !authentication.isFinished {
			_ = try? await session.send(.cancel)
		}
	}
}

// MARK: - Private Interface

private extension WatchModel {
	/// Whether an authentication is in progress, i.e. messages of the iPhone are expected.
	var isAuthenticating: Bool {
		authentication.map { !$0.isFinished } ?? false
	}

	/// Sends an authentication message. The iPhone only acknowledges it, the progress is pushed with
	/// separate messages. Finishes the authentication if the message fails.
	///
	/// - Parameter message: The message to send.
	func send(_ message: WatchMessage) async {
		do throws(WatchError) {
			if case let .failed(error) = try await session.send(message) {
				fail(error)
			}
		} catch {
			fail(error)
		}
	}

	/// Updates the ongoing authentication with a message pushed by the iPhone. Ignored if there is none.
	///
	/// - Parameter message: The pushed message.
	func handle(_ message: PhoneMessage) {
		guard isAuthenticating else {
			return
		}

		switch message {
			case let .credentialRequired(prompt):
				authentication = .credentialRequired(prompt)
			case .continueOnPhone:
				authentication = authenticator.map { .continueOnPhone($0) } ?? .waitingForPhone
			case let .authenticated(username):
				authentication = .succeeded(username: username)
			case let .failed(error):
				authentication = .failed(error)
			case .accounts, .acknowledged:
				break
		}
	}

	/// Finishes the ongoing authentication with an error. Ignored if there is none.
	///
	/// - Parameter error: The reason of the failure.
	func fail(_ error: WatchError) {
		if isAuthenticating {
			authentication = .failed(error)
		}
	}
}
