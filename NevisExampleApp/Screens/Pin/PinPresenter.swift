//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Navigation parameter of the Pin view.
enum PinParameter: NavigationParameterizable {
	/// Represents Pin enrollment
	/// .
	///  - Parameters:
	///    - lastRecoverableError: The object that informs that an error occurred during PIN enrollment.
	///    - handler: The PIN enrollment handler.
	case enrollment(lastRecoverableError: PinEnrollmentError?,
	                handler: PinEnrollmentHandler)

	/// Represents Pin verification.
	///
	///  - Parameters:
	///    - protectionStatus: The object describing the PIN authenticator protection status.
	///    - lastRecoverableError: The object that informs that an error occurred during PIN verification.
	///    - handler: The PIN verification handler.
	case verification(protectionStatus: PinAuthenticatorProtectionStatus,
	                  lastRecoverableError: PinUserVerificationError?,
	                  handler: PinUserVerificationHandler)

	/// Represents Pin change.
	///
	///  - Parameters:
	///    - protectionStatus: The object describing the PIN authenticator protection status.
	///    - lastRecoverableError: The object that informs that an error occurred during PIN change.
	///    - handler: The PIN change handler.
	case credentialChange(protectionStatus: PinAuthenticatorProtectionStatus,
	                      lastRecoverableError: PinChangeRecoverableError?,
	                      handler: PinChangeHandler)
}

/// Presenter of Pin view.
final class PinPresenter {

	/// Available PIN operations.
	enum PinOperation {
		/// PIN enrollment operation.
		case enrollment
		/// PIN change operation.
		case credentialChange
		/// PIN verification operation.
		case verification
	}

	// MARK: - Properties

	/// The view of the presenter.
	weak var view: PinView?

	/// The logger.
	private let logger: SDKLogger

	/// The PIN authenticator protection status.
	private var protectionStatus: PinAuthenticatorProtectionStatus?

	/// Error that can occur during PIN enrollment.
	private var enrollmentError: PinEnrollmentError?

	/// Error that can occur during PIN verification.
	private var verificationError: PinUserVerificationError?

	/// Error that can occur during PIN change.
	private var credentialChangeError: PinChangeRecoverableError?

	/// The PIN enrollment handler.
	private var enrollmentHandler: PinEnrollmentHandler?

	/// The PIN verification handler.
	private var verificationHandler: PinUserVerificationHandler?

	/// The PIN change handler.
	private var credentialChangeHandler: PinChangeHandler?

	/// The current PIN operation.
	private var operation: PinOperation = .enrollment

	/// The cooldown timer.
	private var coolDownTimer: InteractionCountDownTimer?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - logger: The logger.
	///   - parameter: The navigation parameter.
	init(logger: SDKLogger,
	     parameter: NavigationParameterizable? = nil) {
		self.logger = logger
		setParameter(parameter as? PinParameter)
	}

	/// :nodoc:
	deinit {
		os_log("PinPresenter", log: OSLog.deinit, type: .debug)
		// If it is not nil at this moment, it means that a concurrent operation will be started.
		enrollmentHandler?.cancel()
		verificationHandler?.cancel()
		credentialChangeHandler?.cancel()
	}
}

// MARK: - Public Interface

extension PinPresenter {

	/// Returns the actual screen title based on the operation.
	///
	/// - Returns: The actual screen title based on the operation.
	func getTitle() -> String {
		switch operation {
		case .enrollment:
			return L10n.Pin.Enrollment.title
		case .verification:
			return L10n.Pin.Verify.title
		case .credentialChange:
			return L10n.Pin.Change.title
		}
	}

	/// Returns the actual screen description based on the operation.
	///
	/// - Returns: The actual screen description based on the operation.
	func getDescription() -> String {
		switch operation {
		case .enrollment:
			return L10n.Pin.Enrollment.description
		case .verification:
			return L10n.Pin.Verify.description
		case .credentialChange:
			return L10n.Pin.Change.description
		}
	}

	/// Returns the actual operation.
	///
	/// - Returns: The actual operation.
	func getOperation() -> PinOperation {
		operation
	}

	/// Returns the actual last recoverable error based on the operation.
	///
	/// - Returns: The actual last recoverable error based on the operation.
	func getLastRecoverableError() -> String {
		switch operation {
		case .enrollment:
			return enrollmentError?.localizedDescription ?? String()
		case .verification:
			return verificationError?.localizedDescription ?? String()
		case .credentialChange:
			return credentialChangeError?.localizedDescription ?? String()
		}
	}

	/// Handles the PIN authenticator protection status.
	///
	/// - Returns: The actual protection information based on the protection status.
	func getProtectionInfo() -> PinProtectionInformation {
		switch protectionStatus {
		case .Unlocked, .none:
			logger.log("PIN authenticator is unlocked.")
			return .init()
		case let .LastAttemptFailed(remainingTries, coolDown):
			logger.log("Last attempt failed using the PIN authenticator.")
			logger.log("Remaining tries: \(remainingTries), cool down period: \(coolDown).")
			if coolDown > 0 {
				startCoolDownTimer(with: coolDown, remainingTries: remainingTries)
			}

			return .init(message: protectionStatus?.localizedDescription ?? String(),
			             isInCoolDown: coolDown > 0)
		case .LockedOut:
			logger.log("PIN authenticator is locked.")
			return .init(message: protectionStatus?.localizedDescription ?? String())
		case .some:
			logger.log("Unknown PIN authenticator protection status.")
			return .init()
		}
	}

	/// Confirms the given credentials.
	///
	/// - Parameters:
	///  - oldPin: The old PIN.
	///  - pin: The PIN.
	func confirm(oldPin: String, pin: String) {
		logger.log("Confirming entered credentials.")
		view?.disableInteraction()
		switch operation {
		case .enrollment:
			enrollmentHandler?.pin(pin)
			enrollmentHandler = nil
		case .verification:
			verificationHandler?.verify(pin)
			verificationHandler = nil
		case .credentialChange:
			credentialChangeHandler?.pins(oldPin, pin)
			credentialChangeHandler = nil
		}
	}

	/// Cancels the actual operation.
	func cancel() {
		switch operation {
		case .enrollment:
			logger.log("Cancelling PIN enrollment.")
			enrollmentHandler?.cancel()
			enrollmentHandler = nil
		case .verification:
			logger.log("Cancelling PIN verification.")
			verificationHandler?.cancel()
			verificationHandler = nil
		case .credentialChange:
			logger.log("Cancelling PIN change.")
			credentialChangeHandler?.cancel()
			credentialChangeHandler = nil
		}
	}
}

// MARK: - Actions

private extension PinPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: PinParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .enrollment(error, handler):
			operation = .enrollment
			enrollmentError = error
			enrollmentHandler = handler
		case let .verification(status, error, handler):
			operation = .verification
			protectionStatus = status
			verificationError = error
			verificationHandler = handler
		case let .credentialChange(status, error, handler):
			operation = .credentialChange
			protectionStatus = status
			credentialChangeError = error
			credentialChangeHandler = handler
		}
	}

	/// Starts the cooldown timer.
	///
	/// - Parameters:
	///  - cooldown: The cooldown of the timer.
	///  - remainingTries: The number of remaining tries.
	func startCoolDownTimer(with coolDown: Int, remainingTries: Int) {
		coolDownTimer = InteractionCountDownTimer(timerLifeTime: TimeInterval(coolDown)) { remainingCoolDown in
			let status: PinAuthenticatorProtectionStatus = .LastAttemptFailed(remainingTries: remainingTries,
			                                                                  coolDownTimeInSeconds: remainingCoolDown)
			self.view?.update(by: .init(message: status.localizedDescription,
			                            isInCoolDown: remainingCoolDown > 0))
		}

		coolDownTimer?.start()
	}
}
