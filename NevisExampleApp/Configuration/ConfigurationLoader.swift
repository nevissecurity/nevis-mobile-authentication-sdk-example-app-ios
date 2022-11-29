//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Protocol declaration for loading application configuration.
protocol ConfigurationLoader {

	/// The actual environment.
	var environment: Environment { get }

	/// Loads the application configuration.
	///
	/// - Returns: An ``AppConfiguration`` object.
	/// - Throws: An error if any value throws an error during decoding.
	func load() throws -> AppConfiguration?
}
