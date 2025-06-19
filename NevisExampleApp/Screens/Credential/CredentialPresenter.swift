//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

// MARK: - Navigation

/// Navigation parameter of the Credential view.
protocol CredentialParameter: NavigationParameterizable {}

/// Navigation parameter of the Credential view in case of PIN authenticator.
enum PinParameter: CredentialParameter {
	/// Represents PIN enrollment.
	///
	///  - Parameters:
	///    - lastRecoverableError: The object that informs that an error occurred during PIN enrollment.
	///    - handler: The PIN enrollment handler.
	case enrollment(lastRecoverableError: PinEnrollmentError?,
	                handler: PinEnrollmentHandler)

	/// Represents PIN verification.
	///
	///  - Parameters:
	///    - protectionStatus: The object describing the PIN authenticator protection status.
	///    - handler: The PIN verification handler.
	case verification(protectionStatus: PinAuthenticatorProtectionStatus,
	                  handler: PinUserVerificationHandler)

	/// Represents PIN change.
	///
	///  - Parameters:
	///    - protectionStatus: The object describing the PIN authenticator protection status.
	///    - lastRecoverableError: The object that informs that an error occurred during PIN change.
	///    - handler: The PIN change handler.
	case credentialChange(protectionStatus: PinAuthenticatorProtectionStatus,
	                      lastRecoverableError: PinChangeRecoverableError?,
	                      handler: PinChangeHandler)
}

/// Navigation parameter of the Credential view in case of Password authenticator.
enum PasswordParameter: CredentialParameter {
	/// Represents Password enrollment.
	///
	///  - Parameters:
	///    - lastRecoverableError: The object that informs that an error occurred during Password enrollment.
	///    - handler: The Password enrollment handler.
	case enrollment(lastRecoverableError: PasswordEnrollmentError?,
	                handler: PasswordEnrollmentHandler)

	/// Represents Password verification.
	///
	///  - Parameters:
	///    - protectionStatus: The object describing the Password authenticator protection status.
	///    - handler: The Password verification handler.
	case verification(protectionStatus: PasswordAuthenticatorProtectionStatus,
	                  handler: PasswordUserVerificationHandler)

	/// Represents Password change.
	///
	///  - Parameters:
	///    - protectionStatus: The object describing the Password authenticator protection status.
	///    - lastRecoverableError: The object that informs that an error occurred during Password change.
	///    - handler: The Password change handler.
	case credentialChange(protectionStatus: PasswordAuthenticatorProtectionStatus,
	                      lastRecoverableError: PasswordChangeRecoverableError?,
	                      handler: PasswordChangeHandler)
}

// MARK: - Presenter

/// Presenter of Credential view.
final class CredentialPresenter {

	/// Available credential operations.
	enum CredentialOperation {
		/// Enrollment operation.
		case enrollment
		/// Change operation.
		case credentialChange
		/// Verification operation.
		case verification
	}

	// MARK: - Properties

	/// The view of the presenter.
	weak var view: CredentialView?

	/// The current credential type.
	private var credentialType: AuthenticatorAaid = .Pin

	/// The current operation.
	private var operation: CredentialOperation = .enrollment

	/// The cooldown timer.
	private var coolDownTimer: InteractionCountDownTimer?

	// MARK: Pin

	/// The PIN authenticator protection status.
	private var pinProtectionStatus: PinAuthenticatorProtectionStatus?

	/// Error that can occur during PIN enrollment.
	private var pinEnrollmentError: PinEnrollmentError?

	/// Error that can occur during PIN change.
	private var pinCredentialChangeError: PinChangeRecoverableError?

	/// The PIN enrollment handler.
	private var pinEnrollmentHandler: PinEnrollmentHandler?

	/// The PIN verification handler.
	private var pinVerificationHandler: PinUserVerificationHandler?

	/// The PIN change handler.
	private var pinCredentialChangeHandler: PinChangeHandler?

	// MARK: Password

	/// The Password authenticator protection status.
	private var passwordProtectionStatus: PasswordAuthenticatorProtectionStatus?

	/// Error that can occur during Password enrollment.
	private var passwordEnrollmentError: PasswordEnrollmentError?

	/// Error that can occur during Password change.
	private var passwordCredentialChangeError: PasswordChangeRecoverableError?

	/// The Password enrollment handler.
	private var passwordEnrollmentHandler: PasswordEnrollmentHandler?

	/// The Password verification handler.
	private var passwordVerificationHandler: PasswordUserVerificationHandler?

	/// The Password change handler.
	private var passwordCredentialChangeHandler: PasswordChangeHandler?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - parameter: The navigation parameter.
	init(parameter: NavigationParameterizable? = nil) {
		setParameter(parameter as? CredentialParameter)
	}

	deinit {
		logger.deinit("CredentialPresenter")

		// If it is not nil at this moment, it means that a concurrent operation is about to be started.
		pinEnrollmentHandler?.cancel()
		pinVerificationHandler?.cancel()
		pinCredentialChangeHandler?.cancel()

		passwordEnrollmentHandler?.cancel()
		passwordVerificationHandler?.cancel()
		passwordCredentialChangeHandler?.cancel()
	}
}

// MARK: - Public Interface

extension CredentialPresenter {
	/// Returns the actual screen title based on the operation and credential type.
	///
	/// - Returns: The actual screen title based on the operation and credential type.
	func getTitle() -> String {
		switch operation {
		case .enrollment where credentialType == AuthenticatorAaid.Pin:
			L10n.Credential.Pin.Enrollment.title
		case .verification where credentialType == AuthenticatorAaid.Pin:
			L10n.Credential.Pin.Verify.title
		case .credentialChange where credentialType == AuthenticatorAaid.Pin:
			L10n.Credential.Pin.Change.title
		case .enrollment where credentialType == AuthenticatorAaid.Password:
			L10n.Credential.Password.Enrollment.title
		case .verification where credentialType == AuthenticatorAaid.Password:
			L10n.Credential.Password.Verify.title
		case .credentialChange where credentialType == AuthenticatorAaid.Password:
			L10n.Credential.Password.Change.title
		default:
			String()
		}
	}

	/// Returns the actual screen description based on the operation and credential type.
	///
	/// - Returns: The actual screen description based on the operation and credential type.
	func getDescription() -> String {
		switch operation {
		case .enrollment where credentialType == AuthenticatorAaid.Pin:
			L10n.Credential.Pin.Enrollment.description
		case .verification where credentialType == AuthenticatorAaid.Pin:
			L10n.Credential.Pin.Verify.description
		case .credentialChange where credentialType == AuthenticatorAaid.Pin:
			L10n.Credential.Pin.Change.description
		case .enrollment where credentialType == AuthenticatorAaid.Password:
			L10n.Credential.Password.Enrollment.description
		case .verification where credentialType == AuthenticatorAaid.Password:
			L10n.Credential.Password.Verify.description
		case .credentialChange where credentialType == AuthenticatorAaid.Password:
			L10n.Credential.Password.Change.description
		default:
			String()
		}
	}

	/// Returns the actual operation.
	///
	/// - Returns: The actual operation.
	func getOperation() -> CredentialOperation {
		operation
	}

	/// Returns the actual credential type.
	///
	/// - Returns: The actual credential type.
	func getCredentialType() -> AuthenticatorAaid {
		credentialType
	}

	/// Returns the actual last recoverable error based on the operation and credential type.
	///
	/// - Returns: The actual last recoverable error based on the operation and credential type.
	func getLastRecoverableError() -> String {
		switch operation {
		case .enrollment:
			pinEnrollmentError?.localizedDescription ?? passwordEnrollmentError?.localizedDescription ?? String()
		case .verification:
			String()
		case .credentialChange:
			pinCredentialChangeError?.localizedDescription ?? passwordCredentialChangeError?.localizedDescription ?? String()
		}
	}

	/// Handles the authenticator protection status.
	///
	/// - Returns: The actual protection information based on the protection status and the credential type.
	func getProtectionInfo() -> CredentialProtectionInformation {
		if case .Pin = credentialType {
			switch pinProtectionStatus {
			case .Unlocked, .none:
				logger.sdk("PIN authenticator is unlocked.")
				return .init()
			case let .LastAttemptFailed(remainingTries, coolDown):
				logger.sdk("Last attempt failed using the PIN authenticator.")
				logger.sdk("Remaining tries: %d, cool down period: %d.", .black, .debug, remainingTries, coolDown)
				if coolDown > 0 {
					startCoolDownTimer(with: coolDown, remainingTries: remainingTries)
				}

				return .init(message: pinProtectionStatus?.localizedDescription ?? String(),
				             isInCoolDown: coolDown > 0)
			case .LockedOut:
				logger.sdk("PIN authenticator is locked.")
				return .init(message: pinProtectionStatus?.localizedDescription ?? String())
			case .some:
				logger.sdk("Unknown PIN authenticator protection status.")
				return .init()
			}
		}
		else if case .Password = credentialType {
			switch passwordProtectionStatus {
			case .Unlocked, .none:
				logger.sdk("Password authenticator is unlocked.")
				return .init()
			case let .LastAttemptFailed(remainingTries, coolDown):
				logger.sdk("Last attempt failed using the Password authenticator.")
				logger.sdk("Remaining tries: %d, cool down period: %d.", .black, .debug, remainingTries, coolDown)
				if coolDown > 0 {
					startCoolDownTimer(with: coolDown, remainingTries: remainingTries)
				}

				return .init(message: passwordProtectionStatus?.localizedDescription ?? String(),
				             isInCoolDown: coolDown > 0)
			case .LockedOut:
				logger.sdk("Password authenticator is locked.")
				return .init(message: passwordProtectionStatus?.localizedDescription ?? String())
			case .some:
				logger.sdk("Unknown Password authenticator protection status.")
				return .init()
			}
		}
		else {
			return .init()
		}
	}

	/// Confirms the given credentials.
	///
	/// - Parameters:
	///  - oldCredential: The old credential.
	///  - credential: The credential.
	func confirm(oldCredential: String, credential: String) {
		logger.sdk("Confirming entered credentials.")
		view?.disableInteraction()
		switch operation {
		case .enrollment:
			pinEnrollmentHandler?.pin(credential)
			pinEnrollmentHandler = nil
			passwordEnrollmentHandler?.password(credential)
			passwordEnrollmentHandler = nil
		case .verification:
			pinVerificationHandler?.verify(credential)
			pinVerificationHandler = nil
			passwordVerificationHandler?.verify(credential)
			passwordVerificationHandler = nil
		case .credentialChange:
			pinCredentialChangeHandler?.pins(oldCredential, credential)
			pinCredentialChangeHandler = nil
			passwordCredentialChangeHandler?.passwords(oldCredential, credential)
			passwordCredentialChangeHandler = nil
		}
	}

	/// Cancels the actual operation.
	func cancel() {
		switch operation {
		case .enrollment:
			logger.sdk("Cancelling credential enrollment.")
			pinEnrollmentHandler?.cancel()
			pinEnrollmentHandler = nil
			passwordEnrollmentHandler?.cancel()
			passwordEnrollmentHandler = nil
		case .verification:
			logger.sdk("Cancelling credential verification.")
			pinVerificationHandler?.cancel()
			pinVerificationHandler = nil
			passwordVerificationHandler?.cancel()
			passwordVerificationHandler = nil
		case .credentialChange:
			logger.sdk("Cancelling credential change.")
			pinCredentialChangeHandler?.cancel()
			pinCredentialChangeHandler = nil
			passwordCredentialChangeHandler?.cancel()
			passwordCredentialChangeHandler = nil
		}
	}
}

// MARK: - Actions

private extension CredentialPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: CredentialParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		if let parameter = parameter as? PinParameter {
			credentialType = .Pin
			switch parameter {
			case let .enrollment(error, handler):
				operation = .enrollment
				pinEnrollmentError = error
				pinEnrollmentHandler = handler
			case let .verification(status, handler):
				operation = .verification
				pinProtectionStatus = status
				pinVerificationHandler = handler
			case let .credentialChange(status, error, handler):
				operation = .credentialChange
				pinProtectionStatus = status
				pinCredentialChangeError = error
				pinCredentialChangeHandler = handler
			}
		}
		else if let parameter = parameter as? PasswordParameter {
			credentialType = .Password
			switch parameter {
			case let .enrollment(error, handler):
				operation = .enrollment
				passwordEnrollmentError = error
				passwordEnrollmentHandler = handler
			case let .verification(status, handler):
				operation = .verification
				passwordProtectionStatus = status
				passwordVerificationHandler = handler
			case let .credentialChange(status, error, handler):
				operation = .credentialChange
				passwordProtectionStatus = status
				passwordCredentialChangeError = error
				passwordCredentialChangeHandler = handler
			}
		}
		else {
			preconditionFailure("Parameter type mismatch!")
		}
	}

	/// Starts the cooldown timer.
	///
	/// - Parameters:
	///  - cooldown: The cooldown of the timer.
	///  - remainingTries: The number of remaining tries.
	func startCoolDownTimer(with coolDown: Int, remainingTries: Int) {
		coolDownTimer = InteractionCountDownTimer(timerLifeTime: TimeInterval(coolDown)) { remainingCoolDown in
			let localizedDescription = switch self.credentialType {
			case .Pin:
				PinAuthenticatorProtectionStatus.LastAttemptFailed(remainingTries: remainingTries,
				                                                   coolDownTimeInSeconds: remainingCoolDown).localizedDescription
			case .Password:
				PasswordAuthenticatorProtectionStatus.LastAttemptFailed(remainingTries: remainingTries,
				                                                        coolDownTimeInSeconds: remainingCoolDown).localizedDescription
			default:
				String()
			}
			self.view?.update(by: .init(message: localizedDescription,
			                            isInCoolDown: remainingCoolDown > 0))
		}

		coolDownTimer?.start()
	}
}
