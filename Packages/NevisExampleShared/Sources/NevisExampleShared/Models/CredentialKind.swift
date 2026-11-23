//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// The kind of credential the user types.
public enum CredentialKind: String, Codable, Sendable {
	/// PIN authenticator.
	case pin
	/// Password authenticator.
	case password

	// MARK: - Properties

	/// The authenticator the credential belongs to.
	public var authenticator: AuthenticatorKind {
		switch self {
			case .pin:
				.pin
			case .password:
				.password
		}
	}

	/// The localized title of the credential prompt, e.g. "Enter PIN".
	public var localizedPromptTitle: String {
		switch self {
			case .pin:
				L10n.Credential.pinPromptTitle
			case .password:
				L10n.Credential.passwordPromptTitle
		}
	}
}
