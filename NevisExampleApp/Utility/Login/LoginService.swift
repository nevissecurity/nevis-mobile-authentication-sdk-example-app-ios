//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Protocol describing Login related operations.
protocol LoginService {

	/// Sends a login request to the server.
	///
	/// - Parameters:
	///   - request: The request to send.
	///   - handler: The code need to be executed after login.
	func send(request: LoginRequest, completion handler: @escaping (Result<LoginResponse, Error>) -> ())
}
