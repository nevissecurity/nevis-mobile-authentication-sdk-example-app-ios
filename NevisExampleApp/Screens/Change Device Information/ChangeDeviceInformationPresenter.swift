//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication

/// Navigation parameter of the Change Device Information view.
enum ChangeDeviceInformationParameter: NavigationParameterizable {
	/// Represents change device information.
	///
	///  - Parameter deviceInformation: The current device information.
	case change(deviceInformation: DeviceInformation)
}

/// Presenter of Change Device Information view.
final class ChangeDeviceInformationPresenter {
	// MARK: - Properties

	/// The view of the presenter.
	weak var view: BaseView?

	/// The client provider.
	private let clientProvider: ClientProvider

	/// The application coordinator.
	private let appCoordinator: AppCoordinator

	/// The error handler chain.
	private let errorHandlerChain: ErrorHandlerChain

	/// The logger.
	private let logger: SDKLogger

	/// The current device information.
	private var deviceInformation: DeviceInformation?

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - clientProvider: The client provider.
	///   - appCoordinator: The application coordinator.
	///   - errorHandlerChain: The error handler chain.
	///   - logger: The logger.
	///   - parameter: The navigation parameter.
	init(clientProvider: ClientProvider,
	     appCoordinator: AppCoordinator,
	     errorHandlerChain: ErrorHandlerChain,
	     logger: SDKLogger,
	     parameter: NavigationParameterizable? = nil) {
		self.clientProvider = clientProvider
		self.appCoordinator = appCoordinator
		self.errorHandlerChain = errorHandlerChain
		self.logger = logger
		setParameter(parameter as? ChangeDeviceInformationParameter)
	}

	/// :nodoc:
	deinit {
		os_log("ChangeDeviceInformationPresenter", log: OSLog.deinit, type: .debug)
	}
}

// MARK: - Public Interface

extension ChangeDeviceInformationPresenter {

	/// Return the actual device name.
	///
	/// - Returns: The actual device name.
	func getName() -> String? {
		deviceInformation?.name
	}

	/// Changes the name of the device.
	///
	/// - Parameter name: The new device name.
	func change(name: String) {
		view?.disableInteraction()
		let client = clientProvider.get()
		client?.operations.deviceInformationChange
			.name(name)
			.onSuccess {
				self.logger.log("Change device information succeeded.", color: .green)
				self.appCoordinator.navigateToResult(with: .success(operation: .deviceInformationChange))
			}
			.onError {
				self.logger.log("Change device information failed.", color: .red)
				let operationError = OperationError(operation: .deviceInformationChange, underlyingError: $0)
				self.errorHandlerChain.handle(error: operationError)
			}
			.execute()
	}

	/// Cancels device information change.
	func cancel() {
		appCoordinator.start()
	}
}

// MARK: - Private Interface

private extension ChangeDeviceInformationPresenter {

	/// Handles the recevied parameter.
	///
	/// - Parameter paramter: The parameter to handle.
	func setParameter(_ parameter: ChangeDeviceInformationParameter?) {
		guard let parameter else {
			preconditionFailure("Parameter type mismatch!")
		}

		switch parameter {
		case let .change(deviceInformation):
			self.deviceInformation = deviceInformation
		}
	}
}
