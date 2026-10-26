//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

#if canImport(WatchConnectivity)
	import WatchConnectivity

	public extension WCSession {
		/// Sends a message to the counterpart and waits for its reply.
		///
		/// The counterpart must reply to every message, in `session(_:didReceiveMessageData:replyHandler:)`.
		///
		/// - Parameters:
		///   - message: The message to send.
		///   - replyType: The type of the reply.
		/// - Returns: The decoded reply.
		/// - Throws: ``WatchError/unreachable`` if the counterpart is not reachable, ``WatchError/timeout`` if it does
		///   not reply in time, ``WatchError/invalidMessage`` if a message cannot be coded, or
		///   ``WatchError/other(description:)``.
		func send<Reply: Decodable & Sendable>(_ message: some Encodable, replyType: Reply.Type = Reply.self) async throws(WatchError) -> Reply {
			guard activationState == .activated, isReachable else {
				throw .unreachable
			}

			let data = try MessageCoder.encode(message)
			let result: Result<Data, WatchError> = await withCheckedContinuation { continuation in
				sendMessageData(
					data,
					replyHandler: { continuation.resume(returning: .success($0)) },
					errorHandler: { continuation.resume(returning: .failure(WatchError($0))) }
				)
			}
			return try MessageCoder.decode(replyType, from: result.get())
		}
	}

	extension WatchError {
		/// Maps a WatchConnectivity error.
		///
		/// - Parameter error: The error reported by `WCSession`.
		init(_ error: any Error) {
			switch (error as? WCError)?.code {
				case .notReachable?, .deviceNotPaired?, .watchAppNotInstalled?, .companionAppNotInstalled?:
					self = .unreachable
				case .messageReplyTimedOut?:
					self = .timeout
				case .payloadUnsupportedTypes?, .payloadTooLarge?:
					self = .invalidMessage
				default:
					self = .other(description: error.localizedDescription)
			}
		}
	}
#endif
