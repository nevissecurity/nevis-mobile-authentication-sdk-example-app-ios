//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Object representation the content of a deep link.
struct DeepLink {

	// MARK: - Parameter

	/// The available parameters.
	private enum Parameter: String {
		/// The dispatch token response parameter.
		case dispatchTokenResponse
	}

	// MARK: - Properties

	/// The content of the deep link.
	var content: String

	// MARK: - Initialization

	/// Builds a ``DeepLink`` object by processing an url.
	///
	/// - Parameter url: The source of the deep link.
	init?(url: URL) {
		guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
			return nil
		}

		guard let contents = queryItems.first(where: { $0.name == Parameter.dispatchTokenResponse.rawValue })?.value else {
			return nil
		}

		self.content = contents
	}
}
