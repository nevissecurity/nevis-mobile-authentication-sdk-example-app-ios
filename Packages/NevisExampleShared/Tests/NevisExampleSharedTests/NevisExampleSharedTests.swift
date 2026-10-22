//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation
import Testing

@testable import NevisExampleShared

struct MessageCoderTests {
	@Test(arguments: [
		WatchMessage.accounts,
		.authenticate(username: "jdoe", authenticator: .pin),
		.credential("1234"),
		.cancel,
	])
	func watchMessageRoundTrip(message: WatchMessage) throws {
		let data = try MessageCoder.encode(message)
		#expect(try MessageCoder.decode(WatchMessage.self, from: data) == message)
	}

	@Test(arguments: [
		PhoneMessage.accounts([RegisteredAccount(username: "jdoe", authenticators: [.faceRecognition, .pin])]),
		.acknowledged,
		.credentialRequired(CredentialPrompt(kind: .password, username: "jdoe", protection: .lastAttemptFailed(remainingTries: 2, coolDown: 30))),
		.continueOnPhone,
		.authenticated(username: "jdoe"),
		.failed(.other(description: "Boom")),
	])
	func phoneMessageRoundTrip(message: PhoneMessage) throws {
		let data = try MessageCoder.encode(message)
		#expect(try MessageCoder.decode(PhoneMessage.self, from: data) == message)
	}

	@Test func invalidDataThrows() {
		#expect(throws: WatchError.invalidMessage) {
			try MessageCoder.decode(PhoneMessage.self, from: Data("{}".utf8))
		}
	}
}

struct LocalizationTests {
	@Test func authenticatorTitlesAreLocalized() {
		for kind in AuthenticatorKind.allCases {
			#expect(!kind.localizedTitle.isEmpty)
			#expect(!kind.localizedTitle.hasPrefix("authenticator_"))
		}
	}

	@Test func credentialPromptTitles() {
		#expect(CredentialKind.pin.localizedPromptTitle == "Enter PIN")
		#expect(CredentialKind.password.localizedPromptTitle == "Enter password")
	}

	@Test func protectionDescriptions() {
		#expect(CredentialProtection.unlocked.localizedDescription(for: .pin).isEmpty)
		#expect(CredentialProtection.lockedOut.localizedDescription(for: .pin) == "Your PIN is blocked.")
		#expect(CredentialProtection.lastAttemptFailed(remainingTries: 3, coolDown: 0).localizedDescription(for: .password) == "You have 3 tries left.")
		#expect(CredentialProtection.lastAttemptFailed(remainingTries: 1, coolDown: 10).localizedDescription(for: .pin) == "You have 1 try left. Please retry in 10 seconds. After that your PIN will be blocked.")
	}

	@Test func errorsAreLocalized() {
		#expect(WatchError.unreachable.localizedDescription == "The iPhone app is not reachable. Open it on your iPhone.")
		#expect(WatchError.other(description: "Boom").localizedDescription == "Boom")
	}
}
