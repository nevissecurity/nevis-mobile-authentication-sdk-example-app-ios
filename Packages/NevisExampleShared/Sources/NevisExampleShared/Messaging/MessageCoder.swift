//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// Encodes and decodes the ``WatchMessage``s and ``PhoneMessage``s to and from the `Data` sent over WatchConnectivity.
public enum MessageCoder {
	/// Encodes a message.
	///
	/// - Parameter message: The message to encode.
	/// - Returns: The encoded message.
	/// - Throws: ``WatchError/invalidMessage`` if the message cannot be encoded.
	public static func encode(_ message: some Encodable) throws(WatchError) -> Data {
		do {
			return try JSONEncoder().encode(message)
		} catch {
			throw .invalidMessage
		}
	}

	/// Decodes a message.
	///
	/// - Parameters:
	///   - type: The type of the message.
	///   - data: The encoded message.
	/// - Returns: The decoded message.
	/// - Throws: ``WatchError/invalidMessage`` if the data is not a valid message of the type.
	public static func decode<Message: Decodable>(_ type: Message.Type, from data: Data) throws(WatchError) -> Message {
		do {
			return try JSONDecoder().decode(type, from: data)
		} catch {
			throw .invalidMessage
		}
	}
}
