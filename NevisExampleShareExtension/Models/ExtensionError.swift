//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// Extension specific errors.
enum ExtensionError: Error {
	/// The configuration file could not be loaded.
	case configuration
	/// The SDK client is not initialized.
	case notInitialized
	/// No account is selected or the selected account is not found.
	case accountNotFound
}

// MARK: - LocalizedError

extension ExtensionError: LocalizedError {
	/// The localized message describing the error.
	var errorDescription: String? {
		switch self {
			case .configuration:
				L10n.Error.configuration
			case .notInitialized:
				L10n.Error.notInitialized
			case .accountNotFound:
				L10n.Error.accountNotFound
		}
	}
}
