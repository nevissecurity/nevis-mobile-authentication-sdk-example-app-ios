//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// The authenticators supported by the example apps.
///
/// Mirrors the SDK's `AuthenticatorAaid`, so it can be used on platforms where the SDK is not available (watchOS).
/// The raw value is the AAID.
public enum AuthenticatorKind: String, Codable, Sendable, CaseIterable, Identifiable {
	/// PIN authenticator.
	case pin = "F1D0#1001"
	/// Touch ID authenticator.
	case fingerprint = "F1D0#1002"
	/// Face ID authenticator.
	case faceRecognition = "F1D0#1003"
	/// Device passcode authenticator.
	case devicePasscode = "F1D0#1004"
	/// Password authenticator.
	case password = "F1D0#1005"

	// MARK: - Properties

	/// The identifier of the authenticator. The AAID.
	public var id: String { rawValue }

	/// The AAID of the authenticator.
	public var aaid: String { rawValue }

	/// The localized title of the authenticator.
	public var localizedTitle: String {
		switch self {
			case .pin:
				L10n.Authenticator.pin
			case .fingerprint:
				L10n.Authenticator.fingerprint
			case .faceRecognition:
				L10n.Authenticator.faceRecognition
			case .devicePasscode:
				L10n.Authenticator.devicePasscode
			case .password:
				L10n.Authenticator.password
		}
	}

	/// The SF Symbol name of the authenticator.
	public var systemImage: String {
		switch self {
			case .pin:
				"square.grid.3x3"
			case .fingerprint:
				"touchid"
			case .faceRecognition:
				"faceid"
			case .devicePasscode:
				"ellipsis.rectangle"
			case .password:
				"key"
		}
	}

	/// The credential the user types for the authenticator. `nil` for system verified authenticators.
	public var credentialKind: CredentialKind? {
		switch self {
			case .pin:
				.pin
			case .password:
				.password
			case .fingerprint, .faceRecognition, .devicePasscode:
				nil
		}
	}

	/// Whether the user verification must happen on the device holding the credential.
	///
	/// Biometric and device passcode verification is presented by the system, so it cannot be done remotely
	/// (e.g. from the watch). PIN and password are verified by the SDK and can be entered anywhere.
	public var requiresLocalVerification: Bool {
		credentialKind == nil
	}
}
