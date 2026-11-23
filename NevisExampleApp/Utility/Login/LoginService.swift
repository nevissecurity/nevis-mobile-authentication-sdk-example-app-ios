//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Protocol describing Login related operations.
protocol LoginService: Sendable {

	/// Sends a login request to the server.
	///
	/// - Parameters:
	///   - request: The request to send.
	/// - Returns: The login response.
	func send(request: LoginRequest) async throws -> LoginResponse
}
