//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Default implementation of ``LoginService`` protocol.
final class LoginServiceImpl: Sendable {

	// MARK: - Properties

	/// The used URL session.
	private let session: URLSession

	// MARK: - Initialization

	/// Creates a new instance.
	init() {
		self.session = URLSession(
			configuration: .ephemeral,
			delegate: LoginSessionDelegate(),
			delegateQueue: nil
		)
	}
}

// MARK: - LoginService

extension LoginServiceImpl: LoginService {

	func send(request: LoginRequest) async throws -> LoginResponse {
		var httpRequest = URLRequest(url: request.url)
		httpRequest.httpMethod = "POST"
		httpRequest.addValue(
			"application/x-www-form-urlencoded;charset=utf-8",
			forHTTPHeaderField: "Content-Type"
		)
		let requestData = try JSONEncoder().encode(request)
		guard let parameters = try JSONSerialization.jsonObject(with: requestData) as? [String: String] else {
			throw AppError.loginError
		}

		httpRequest.httpBody = parameters.urlEncoded().data(using: .utf8)
		let (responseData, urlResponse) = try await session.data(for: httpRequest)
		guard let httpResponse = urlResponse as? HTTPURLResponse else {
			throw AppError.loginError
		}

		var response = try JSONDecoder().decode(LoginResponse.self, from: responseData)
		let headerFields = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
			if let key = pair.key as? String, let value = pair.value as? String {
				result[key] = value
			}
		}
		response.cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: request.url)
		return response
	}
}

// MARK: - LoginSessionDelegate

/// Login specific implementation of `URLSessionDelegate` protocol.
final class LoginSessionDelegate: NSObject, URLSessionDelegate {

	/// Requests credentials from the delegate in response to a session-level authentication request from the remote server.
	///
	/// - Parameters:
	///   - session: The session containing the task that requested authentication.
	///   - challenge: An object that contains the request for authentication.
	///   - completionHandler: A handler that your delegate method must call.
	// swiftformat:disable:next unusedArguments
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> ()) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			let serverTrust = challenge.protectionSpace.serverTrust
		{
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
			completionHandler(.performDefaultHandling, nil)
		}
	}
}
