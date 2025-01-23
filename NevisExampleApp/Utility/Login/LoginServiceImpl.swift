//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Default implementation of ``LoginService`` protocol.
class LoginServiceImpl {

	// MARK: - Properties

	/// The used URL session.
	private let session: URLSession

	// MARK: - Initialization

	/// Creates a new instance.
	init() {
		self.session = URLSession(configuration: .ephemeral,
		                          delegate: LoginSessionDelegate(),
		                          delegateQueue: nil)
	}
}

// MARK: - LoginService

extension LoginServiceImpl: LoginService {

	func send(request: LoginRequest, completion handler: @escaping (Result<LoginResponse, Error>) -> ()) {
		do {
			var httpRequest = URLRequest(url: request.url)
			httpRequest.httpMethod = "POST"
			httpRequest.addValue("application/x-www-form-urlencoded;charset=utf-8",
			                     forHTTPHeaderField: "Content-Type")
			let requestData = try JSONEncoder().encode(request)
			guard let parameters = try JSONSerialization.jsonObject(with: requestData) as? [String: String] else {
				return handler(.failure(AppError.loginError))
			}

			let urlEncodedBody = parameters.urlEncoded()
			httpRequest.httpBody = urlEncodedBody.data(using: .utf8)
			let task = session.dataTask(with: httpRequest) { responseData, urlResponse, error in
				if let error {
					return DispatchQueue.main.async { handler(.failure(error)) }
				}

				do {
					guard let responseData, let httpResponse = urlResponse as? HTTPURLResponse else {
						return DispatchQueue.main.async { handler(.failure(AppError.loginError)) }
					}

					var response = try JSONDecoder().decode(LoginResponse.self, from: responseData)
					let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String: String],
					                                 for: request.url)
					response.cookies = cookies
					DispatchQueue.main.async { handler(.success(response)) }
				}
				catch {
					DispatchQueue.main.async { handler(.failure(error)) }
				}
			}

			task.resume()
		}
		catch {
			return handler(.failure(error))
		}
	}
}

// MARK: - LoginSessionDelegate

/// Login specific implementation of `URLSessionDelegate` protocol.
class LoginSessionDelegate: NSObject, URLSessionDelegate {

	/// Requests credentials from the delegate in response to a session-level authentication request from the remote server.
	///
	/// - Parameters:
	///   - session: The session containing the task that requested authentication.
	///   - challenge: An object that contains the request for authentication.
	///   - completionHandler: A handler that your delegate method must call.
	// swiftformat:disable:next unusedArguments
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> ()) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
		   let serverTrust = challenge.protectionSpace.serverTrust {
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		}
		else {
			completionHandler(.performDefaultHandling, nil)
		}
	}
}
