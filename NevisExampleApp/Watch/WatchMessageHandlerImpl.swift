//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication
import UIKit

/// Default implementation of `WatchMessageHandler`.
///
/// Authenticates on behalf of the watch with ``HeadlessAuthentication``. The progress is pushed to the watch with
/// ``WatchMessageSender``: the PIN or password is requested from the watch, biometric and device passcode
/// verification is presented on the iPhone. The system prompt can only be presented in the foreground, so if the app
/// is not active, the verification starts when the user opens the app.
@MainActor
final class WatchMessageHandlerImpl {
	// MARK: - Properties

	/// The time the watch has to answer a credential request, in nanoseconds.
	private static let credentialTimeout: UInt64 = 60 * NSEC_PER_SEC

	/// The time the user has to open the app for a biometric or device passcode verification, in nanoseconds.
	/// Shorter than the background execution time the system grants to the app.
	private static let foregroundTimeout: UInt64 = 25 * NSEC_PER_SEC

	/// The configuration loader.
	private let configurationLoader: ConfigurationLoader

	/// The client initializer.
	private let clientInitializer: ClientInitializer

	/// The client provider.
	private let clientProvider: ClientProvider

	/// Pushes the progress of the authentication to the watch.
	private let sender: WatchMessageSender

	/// The ongoing authentication. `nil` if there is none.
	private var authentication: Task<Void, Never>?

	/// Whether the watch cancelled the ongoing authentication.
	private var isCancelled = false

	/// Waits for the credential of the watch. `nil` if no credential is requested.
	private var credentialContinuation: CheckedContinuation<String?, Never>?

	/// Ends the wait for the credential after ``credentialTimeout``.
	private var credentialTimeoutTask: Task<Void, Never>?

	/// Waits for the app to become active. `nil` if the app is not waited for.
	private var activeContinuation: CheckedContinuation<Bool, Never>?

	/// Observes the app becoming active.
	private var activeObserver: NSObjectProtocol?

	/// Ends the wait for the app after ``foregroundTimeout``.
	private var activeTimeoutTask: Task<Void, Never>?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - configurationLoader: The configuration loader.
	///   - clientInitializer: The client initializer.
	///   - clientProvider: The client provider.
	///   - sender: Pushes the progress of the authentication to the watch.
	init(
		configurationLoader: ConfigurationLoader,
		clientInitializer: ClientInitializer,
		clientProvider: ClientProvider,
		sender: WatchMessageSender
	) {
		self.configurationLoader = configurationLoader
		self.clientInitializer = clientInitializer
		self.clientProvider = clientProvider
		self.sender = sender
	}
}

// MARK: - WatchMessageHandler

extension WatchMessageHandlerImpl: WatchMessageHandler {
	func handle(_ message: WatchMessage) async -> PhoneMessage {
		let client: MobileAuthenticationClient
		do throws(WatchError) {
			client = try await initializedClient()
		} catch {
			return .failed(error)
		}

		switch message {
			case .accounts:
				return .accounts(client.localData.registeredAccounts(allowlist: allowlist))
			case let .authenticate(username, authenticator):
				return authenticate(username, using: authenticator, client: client)
			case let .credential(credential):
				return provide(credential)
			case .cancel:
				return cancel()
		}
	}
}

// MARK: - Private Interface

private extension WatchMessageHandlerImpl {
	/// The authenticators allowed by the configuration.
	var allowlist: [AuthenticatorAaid] {
		(try? configurationLoader.load())?.authenticatorAllowlist ?? []
	}

	/// Returns the initialized client. Initializes it first if needed.
	///
	/// - Returns: The initialized client.
	/// - Throws: `WatchError.initializationFailed` if the client could not be initialized.
	func initializedClient() async throws(WatchError) -> MobileAuthenticationClient {
		do {
			try await clientInitializer.initialize()
		} catch {
			logger.sdk("Client initialization failed: %@", .red, .error, error.localizedDescription)
			throw .initializationFailed
		}

		guard let client = clientProvider.get() else {
			throw .initializationFailed
		}

		return client
	}

	/// Starts an authentication in the background. The progress and the result are pushed to the watch.
	///
	/// - Parameters:
	///   - username: The account to authenticate.
	///   - authenticator: The authenticator to use.
	///   - client: The initialized client.
	/// - Returns: `PhoneMessage.acknowledged` if the authentication started, `PhoneMessage.failed(_:)` otherwise.
	func authenticate(_ username: String, using authenticator: AuthenticatorKind, client: MobileAuthenticationClient) -> PhoneMessage {
		guard authentication == nil else {
			return .failed(.operationInProgress)
		}

		let allowlist = allowlist
		let isRegistered = client.localData.registeredAccounts(allowlist: allowlist).contains {
			$0.username == username && $0.authenticators.contains(authenticator)
		}

		guard isRegistered else {
			return .failed(.accountNotFound)
		}

		logger.sdk("Authenticating %@ with %@ on behalf of the watch.", .blue, .debug, username, authenticator.localizedTitle)
		isCancelled = false
		authentication = Task {
			// The watch message may have launched the app in the background, keep it running until the result is sent.
			let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "WatchAuthentication")
			defer { UIApplication.shared.endBackgroundTask(backgroundTask) }

			if authenticator.requiresLocalVerification {
				await push(.continueOnPhone)
				guard await waitUntilActive() else {
					await push(.failed(isCancelled ? .cancelled : .phoneAppNotOpened))
					authentication = nil
					return
				}
			}

			let result: PhoneMessage
			do {
				_ = try await HeadlessAuthentication.authenticate(
					username,
					using: authenticator,
					client: client,
					allowlist: allowlist,
					credentialProvider: { [weak self] prompt in
						await self?.requestCredential(prompt)
					}
				)
				result = .authenticated(username: username)
			} catch HeadlessAuthenticationError.cancelled {
				result = .failed(.cancelled)
			} catch let HeadlessAuthenticationError.lockedOut(authenticator) {
				result = .failed(.lockedOut(authenticator: authenticator))
			} catch {
				logger.sdk("Authentication on behalf of the watch failed: %@", .red, .error, error.localizedDescription)
				result = .failed(.other(description: error.localizedDescription))
			}

			// The authentication can end, e.g. with a timeout, while a credential request is still pending.
			resumeCredential(nil)
			await push(result)
			authentication = nil
		}

		return .acknowledged
	}

	/// Asks the watch for the PIN or password and waits for the answer.
	///
	/// - Parameter prompt: The credential request.
	/// - Returns: The credential. `nil` if the watch cancelled, could not be reached or did not answer in time.
	func requestCredential(_ prompt: CredentialPrompt) async -> String? {
		guard !isCancelled, await push(.credentialRequired(prompt)), !isCancelled else {
			return nil
		}

		return await withCheckedContinuation { continuation in
			credentialContinuation = continuation
			credentialTimeoutTask = Task { [weak self] in
				try? await Task.sleep(nanoseconds: Self.credentialTimeout)
				guard !Task.isCancelled else {
					return
				}

				self?.resumeCredential(nil)
			}
		}
	}

	/// Forwards the credential of the watch to the waiting authentication.
	///
	/// - Parameter credential: The credential entered on the watch.
	/// - Returns: `PhoneMessage.acknowledged`, or `PhoneMessage.failed(_:)` if no credential is requested.
	func provide(_ credential: String) -> PhoneMessage {
		guard credentialContinuation != nil else {
			return .failed(.cancelled)
		}

		resumeCredential(credential)
		return .acknowledged
	}

	/// Cancels the ongoing authentication.
	///
	/// A pending credential request is cancelled immediately. Biometric and device passcode verification cannot be
	/// cancelled remotely, the user has to cancel the system prompt on the iPhone.
	///
	/// - Returns: `PhoneMessage.acknowledged`.
	func cancel() -> PhoneMessage {
		if authentication != nil {
			isCancelled = true
		}

		resumeActive(false)
		resumeCredential(nil)
		return .acknowledged
	}

	/// Waits until the app becomes active, so the system prompt of the verification can be presented.
	///
	/// - Returns: `true` if the app is active, `false` on timeout or cancellation.
	func waitUntilActive() async -> Bool {
		guard UIApplication.shared.applicationState != .active else {
			return true
		}

		// The state check and the subscription run on the main actor in one go, the notification cannot be missed.
		let isActive = await withCheckedContinuation { continuation in
			activeContinuation = continuation
			activeObserver = NotificationCenter.default.addObserver(
				forName: UIApplication.didBecomeActiveNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				MainActor.assumeIsolated {
					self?.resumeActive(true)
				}
			}
			activeTimeoutTask = Task { [weak self] in
				try? await Task.sleep(nanoseconds: Self.foregroundTimeout)
				guard !Task.isCancelled else {
					return
				}

				self?.resumeActive(false)
			}
		}

		return isActive && !isCancelled
	}

	/// Ends the wait for the app to become active.
	///
	/// - Parameter isActive: Whether the app became active.
	func resumeActive(_ isActive: Bool) {
		activeTimeoutTask?.cancel()
		activeTimeoutTask = nil
		if let activeObserver {
			NotificationCenter.default.removeObserver(activeObserver)
		}
		activeObserver = nil
		activeContinuation?.resume(returning: isActive)
		activeContinuation = nil
	}

	/// Ends the wait for the credential.
	///
	/// - Parameter credential: The credential. `nil` to cancel.
	func resumeCredential(_ credential: String?) {
		credentialTimeoutTask?.cancel()
		credentialTimeoutTask = nil
		credentialContinuation?.resume(returning: credential)
		credentialContinuation = nil
	}

	/// Pushes a message to the watch.
	///
	/// - Parameter message: The message to push.
	/// - Returns: Whether the watch received the message.
	@discardableResult
	func push(_ message: PhoneMessage) async -> Bool {
		do {
			try await sender.send(message)
			return true
		} catch {
			logger.app("Message cannot be sent to the watch: %@", .red, .error, error.localizedDescription)
			return false
		}
	}
}
