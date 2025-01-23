//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Describes Out-of-Band Payload handling related operations.
/// For more information please read the official documentation about [payload decode](https://docs.nevis.net/mobilesdk/guide/operation/other-operations#obtain-an-out-of-band-payload), [out-of-band registration](https://docs.nevis.net/mobilesdk/guide/operation/registration#out-of-band-registration) and [out-of-band authentication](https://docs.nevis.net/mobilesdk/guide/operation/authentication#out-of-band-authentication).
protocol OutOfBandOperationHandler {

	/// Handles the given payload.
	///
	/// - Parameter payload: The payload to handle.
	func handle(payload: String)
}
