//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// Domain model of a FIDO UAF operation.
public enum Operation {
	/// Client initialization operation.
	case initClient

	/// Out-of-Band payload decode operation.
	case payloadDecode

	/// Out-of-Band operation.
	case outOfBand

	/// FIDO registration operation.
	case registration

	/// FIDO authentication operation.
	case authentication

	/// FIDO deregistration operation.
	case deregistration

	/// PIN change operation.
	case pinChange

	/// Password change operation.
	case passwordChange

	/// Device information change operation.
	case deviceInformationChange

	/// Local data operation.
	case localData

	/// Unknown operation.
	case unknown

	/// Returns the localized title.
	var localizedTitle: String {
		switch self {
		case .initClient:
			L10n.Operation.InitClient.title
		case .payloadDecode:
			L10n.Operation.PayloadDecode.title
		case .outOfBand:
			L10n.Operation.OutOfBand.title
		case .registration:
			L10n.Operation.Registration.title
		case .authentication:
			L10n.Operation.Authentication.title
		case .deregistration:
			L10n.Operation.Deregistration.title
		case .pinChange:
			L10n.Operation.PinChange.title
		case .passwordChange:
			L10n.Operation.PasswordChange.title
		case .deviceInformationChange:
			L10n.Operation.DeviceInformationChange.title
		case .localData:
			L10n.Operation.LocalData.title
		case .unknown:
			String()
		}
	}
}
