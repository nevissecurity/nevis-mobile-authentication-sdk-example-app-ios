//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Default implementation of ``ConfigurationLoader`` protocol.
class ConfigurationLoaderImpl {

	// MARK: - Properties

	/// The actual environment.
	let environment: Environment

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameter environment: The actual environment.
	init(environment: Environment) {
		self.environment = environment
	}
}

// MARK: - ConfigurationLoader

extension ConfigurationLoaderImpl: ConfigurationLoader {

	func load() throws -> AppConfiguration? {
		guard let url = Bundle.main.url(forResource: environment.configFileName,
		                                withExtension: "plist") else {
			return nil
		}

		let data = try Data(contentsOf: url)
		return try PropertyListDecoder().decode(AppConfiguration.self, from: data)
	}
}
