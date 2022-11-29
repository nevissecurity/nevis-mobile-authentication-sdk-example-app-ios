//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

extension String {

	/// Returns a string escaped for `application/x-www-form-urlencoded` encoding.
	///
	/// - Returns: The encoded string.
	func escape() -> String {
		var characterSet = CharacterSet.urlQueryAllowed
		characterSet.insert(charactersIn: " ")
		characterSet.remove(charactersIn: "+/?")

		return addingPercentEncoding(withAllowedCharacters: characterSet)!
			.replacingOccurrences(of: " ", with: "+")
	}
}

extension String? {

	/// Tells whether a string is empty or `nil`.
	var isEmptyOrNil: Bool {
		self?.isEmpty ?? true
	}
}
