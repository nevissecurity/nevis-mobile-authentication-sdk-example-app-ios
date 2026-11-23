//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation
import NevisMobileAuthentication

/// Object describing application configuration
struct AppConfiguration: Codable {

	// MARK: - Properties

	/// The login configuration.
	let loginConfiguration: LoginConfiguration

	/// The Nevis Mobile Authentication SDK configuration.
	let sdkConfiguration: Configuration

	/// The allowed authenticators.
	let authenticatorAllowlist: [AuthenticatorAaid]

	// MARK: - CodingKey

	/// Enumeration for keys used during coding.
	enum CodingKeys: String, CodingKey {
		/// Key for the login configuration.
		case loginConfiguration = "login"
		/// Key for the SDK configuration.
		case sdkConfiguration = "sdk"
		/// Key for the authenticator allowlist.
		case authenticatorAllowlist

		/// Enumeration for the Auth Cloud specific configuration keys used during coding.
		enum AuthCloudCodingKeys: String, CodingKey {
			/// Key for the host name.
			case hostName
			/// Key for the app extension related configuration.
			case appExtension
		}
	}

	// MARK: - Decodable

	/// Creates a new instance by decoding from the given decoder.
	///
	/// - Parameter decoder: The decoder to read data from.
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.loginConfiguration = try container.decode(LoginConfiguration.self, forKey: .loginConfiguration)
		let sdkContainer = try container.nestedContainer(keyedBy: CodingKeys.AuthCloudCodingKeys.self, forKey: .sdkConfiguration)
		let hostName = try sdkContainer.decodeIfPresent(String.self, forKey: .hostName)
		if let hostName {
			let appExtension = try sdkContainer.decodeIfPresent(Configuration.AppExtension.self, forKey: .appExtension)
			if Bundle.main.isAppExtension, let appExtension {
				self.sdkConfiguration = Configuration(authCloudHostname: hostName, appExtension: appExtension)
			} else {
				// using the convenience initializer
				self.sdkConfiguration = Configuration(authCloudHostname: hostName)
			}
		} else {
			let configuration = try container.decode(Configuration.self, forKey: .sdkConfiguration)
			self.sdkConfiguration = Bundle.main.isAppExtension ? configuration : configuration.withoutAppExtension()
		}
		self.authenticatorAllowlist = try container.decode([AuthenticatorAaid].self, forKey: .authenticatorAllowlist)
	}
}

private extension Configuration {
	/// Returns a copy of the configuration without the app extension related configuration,
	/// which must be used only by the app extension, not by the containing app.
	func withoutAppExtension() -> Configuration {
		Configuration(
			baseUrl: baseUrl,
			registrationRequestPath: registrationRequestPath,
			registrationResponsePath: registrationResponsePath,
			authenticationRequestPath: authenticationRequestPath,
			authenticationResponsePath: authenticationResponsePath,
			deregistrationRequestPath: deregistrationRequestPath,
			dispatchTargetResourcePath: dispatchTargetResourcePath,
			deviceResourcePath: deviceResourcePath,
			networkTimeoutInSeconds: networkTimeoutInSeconds,
			userInteractionTimeoutInSeconds: userInteractionTimeoutInSeconds
		)
	}
}
