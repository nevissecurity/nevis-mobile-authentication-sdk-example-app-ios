//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import WatchConnectivity
import os

/// Default implementation of ``PhoneSession`` backed by the default `WCSession`.
final class PhoneSessionImpl: NSObject {
	// MARK: - Properties

	let reachabilityUpdates: AsyncStream<Bool>

	let messages: AsyncStream<PhoneMessage>

	/// Feeds ``reachabilityUpdates``.
	private let reachabilityContinuation: AsyncStream<Bool>.Continuation

	/// Feeds ``messages``. Fed directly from the delegate callbacks to keep the order of the messages.
	private nonisolated let messageContinuation: AsyncStream<PhoneMessage>.Continuation

	/// The messages waiting for the activation to complete.
	private var activationWaiters = [CheckedContinuation<Void, Never>]()

	/// Whether the activation is in progress.
	private var isActivating = false

	/// The logger of the session.
	private nonisolated static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "PhoneSession")

	// MARK: - Initialization

	override init() {
		(reachabilityUpdates, reachabilityContinuation) = AsyncStream.makeStream(bufferingPolicy: .bufferingNewest(1))
		(messages, messageContinuation) = AsyncStream.makeStream()
		super.init()
	}
}

// MARK: - PhoneSession

extension PhoneSessionImpl: PhoneSession {
	func activate() {
		guard WCSession.isSupported(), !isActivating, WCSession.default.activationState != .activated else {
			return
		}

		isActivating = true
		WCSession.default.delegate = self
		WCSession.default.activate()
	}

	func send(_ message: WatchMessage) async throws(WatchError) -> PhoneMessage {
		if isActivating {
			await withCheckedContinuation { activationWaiters.append($0) }
		}

		return try await WCSession.default.send(message, replyType: PhoneMessage.self)
	}
}

// MARK: - WCSessionDelegate

extension PhoneSessionImpl: WCSessionDelegate {
	nonisolated func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
		if let error {
			Self.logger.error("Activation failed: \(error.localizedDescription)")
		} else {
			Self.logger.debug("Activation completed with state: \(activationState.rawValue)")
		}

		Task { @MainActor in
			activationDidComplete()
		}
	}

	nonisolated func session(_: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> ()) {
		let reply: PhoneMessage
		do throws(WatchError) {
			messageContinuation.yield(try MessageCoder.decode(PhoneMessage.self, from: messageData))
			reply = .acknowledged
		} catch {
			Self.logger.error("Invalid message received: \(error.localizedDescription)")
			reply = .failed(error)
		}

		replyHandler((try? MessageCoder.encode(reply)) ?? Data())
	}

	nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
		let isReachable = session.isReachable
		Task { @MainActor in
			reachabilityContinuation.yield(isReachable)
		}
	}
}

// MARK: - Private Interface

private extension PhoneSessionImpl {
	/// Resumes the messages waiting for the activation. The activation state is checked when sending.
	func activationDidComplete() {
		isActivating = false
		activationWaiters.forEach { $0.resume() }
		activationWaiters.removeAll()
	}
}
