//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import NevisMobileAuthentication
import Swinject
import SwinjectAutoregistration

/// The application DI configuration assembly.
final class AppAssembly {}

// MARK: - Assembly

extension AppAssembly: Assembly {

	func assemble(container: Container) {
		registerScreens(container: container)
		registerCoordinators(container: container)
		registerPresenters(container: container)
		registerComponents(container: container)
	}
}

// MARK: - Private Interface

private extension AppAssembly {

	// MARK: Screens

	/// Registers the screens.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerScreens(container: Container) {
		container.autoregisterOnMain(LaunchScreen.self, initializer: LaunchScreen.init)
			.inObjectScope(.weak)

		container.autoregisterOnMain(HomeScreen.self, initializer: HomeScreen.init)
			.inObjectScope(.weak)

		container.autoregisterOnMain(QrScannerScreen.self, initializer: QrScannerScreen.init)
			.inObjectScope(.weak)

		container.registerOnMain(ChangeDeviceInformationScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			ChangeDeviceInformationScreen(presenter: res ~> (ChangeDeviceInformationPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.autoregisterOnMain(AuthCloudApiRegistrationScreen.self, initializer: AuthCloudApiRegistrationScreen.init)
			.inObjectScope(.weak)

		container.autoregisterOnMain(UsernamePasswordLoginScreen.self, initializer: UsernamePasswordLoginScreen.init)
			.inObjectScope(.weak)

		container.registerOnMain(SelectAccountScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			SelectAccountScreen(presenter: res ~> (SelectAccountPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.registerOnMain(SelectAuthenticatorScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			SelectAuthenticatorScreen(presenter: res ~> (SelectAuthenticatorPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.registerOnMain(CredentialScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			CredentialScreen(presenter: res ~> (CredentialPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.registerOnMain(TransactionConfirmationScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			TransactionConfirmationScreen(presenter: res ~> (TransactionConfirmationPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.registerOnMain(ConfirmationScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			ConfirmationScreen(presenter: res ~> (ConfirmationPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.registerOnMain(ResultScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			ResultScreen(presenter: res ~> (ResultPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.autoregisterOnMain(
			LoggingScreen.self,
			initializer: LoggingScreen.init
		)
		.inObjectScope(.container)
	}

	// MARK: Coordinators

	/// Registers the coordinators.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerCoordinators(container: Container) {
		container.autoregisterOnMain(AppCoordinator.self, initializer: AppCoordinatorImpl.init)
			.inObjectScope(.container)
	}

	// MARK: Presenters

	/// Registers the presenters.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerPresenters(container: Container) {
		container.autoregisterOnMain(LaunchPresenter.self, initializer: LaunchPresenter.init)
			.inObjectScope(.transient)

		container.autoregisterOnMain(HomePresenter.self, initializer: HomePresenter.init)
			.inObjectScope(.transient)

		container.autoregisterOnMain(QrScannerPresenter.self, initializer: QrScannerPresenter.init)
			.inObjectScope(.transient)

		container.autoregisterOnMain(
			ChangeDeviceInformationPresenter.self,
			argument: NavigationParameterizable.self,
			initializer: ChangeDeviceInformationPresenter.init
		)
		.inObjectScope(.transient)

		container.registerOnMain(AuthCloudApiRegistrationPresenter.self) { res in
			let authenticatorSelector = res ~> (AuthenticatorSelector.self, name: RegistrationAuthenticatorSelectorName)
			return AuthCloudApiRegistrationPresenter(
				clientProvider: res~>,
				authenticatorSelector: authenticatorSelector,
				pinEnroller: res~>,
				passwordEnroller: res~>,
				biometricUserVerifier: res~>,
				devicePasscodeUserVerifier: res~>,
				appCoordinator: res~>,
				errorHandlerChain: res~>
			)
		}.inObjectScope(.transient)

		container.registerOnMain(UsernamePasswordLoginPresenter.self) { res in
			let authenticatorSelector = res ~> (AuthenticatorSelector.self, name: RegistrationAuthenticatorSelectorName)
			return UsernamePasswordLoginPresenter(
				configurationLoader: res~>,
				loginService: res~>,
				clientProvider: res~>,
				authenticatorSelector: authenticatorSelector,
				pinEnroller: res~>,
				passwordEnroller: res~>,
				biometricUserVerifier: res~>,
				devicePasscodeUserVerifier: res~>,
				appCoordinator: res~>,
				errorHandlerChain: res~>
			)
		}.inObjectScope(.transient)

		container.registerOnMain(SelectAccountPresenter.self) { res, arg in
			let authenticatorSelector = res ~> (AuthenticatorSelector.self, name: AuthenticationAuthenticatorSelectorName)
			return SelectAccountPresenter(
				clientProvider: res~>,
				authenticatorSelector: authenticatorSelector,
				pinChanger: res~>,
				pinUserVerifier: res~>,
				passwordChanger: res~>,
				passwordUserVerifier: res~>,
				biometricUserVerifier: res~>,
				devicePasscodeUserVerifier: res~>,
				appCoordinator: res~>,
				errorHandlerChain: res~>,
				parameter: arg
			)
		}.inObjectScope(.transient)

		container.autoregisterOnMain(
			SelectAuthenticatorPresenter.self,
			argument: NavigationParameterizable.self,
			initializer: SelectAuthenticatorPresenter.init
		)
		.inObjectScope(.transient)

		container.autoregisterOnMain(
			CredentialPresenter.self,
			argument: NavigationParameterizable.self,
			initializer: CredentialPresenter.init
		)
		.inObjectScope(.transient)

		container.autoregisterOnMain(
			TransactionConfirmationPresenter.self,
			argument: NavigationParameterizable.self,
			initializer: TransactionConfirmationPresenter.init
		)
		.inObjectScope(.transient)

		container.autoregisterOnMain(
			ResultPresenter.self,
			argument: NavigationParameterizable.self,
			initializer: ResultPresenter.init
		)
		.inObjectScope(.transient)

		container.autoregisterOnMain(
			ConfirmationPresenter.self,
			argument: NavigationParameterizable.self,
			initializer: ConfirmationPresenter.init
		)
		.inObjectScope(.transient)

		container.autoregisterOnMain(LoggingPresenter.self, initializer: LoggingPresenter.init)
			.inObjectScope(.transient)
	}

	// MARK: Components

	/// Registers the components.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerComponents(container: Container) {
		container.register(ConfigurationLoader.self) { _ in
			ConfigurationLoaderImpl(environment: .authenticationCloud)
		}

		container.autoregisterOnMain(ClientInitializer.self, initializer: ClientInitializerImpl.init)
			.inObjectScope(.container)

		container.autoregister(ClientProvider.self, initializer: ClientProviderImpl.init)
			.inObjectScope(.container)

		container.autoregister(WatchSessionDelegate.self, initializer: WatchSessionDelegateImpl.init)
			.inObjectScope(.container)

		container.autoregister(WatchMessageSender.self, initializer: WatchMessageSenderImpl.init)

		container.autoregisterOnMain(WatchMessageHandler.self, initializer: WatchMessageHandlerImpl.init)
			.inObjectScope(.container)

		container.autoregister(AccountSelector.self, initializer: AccountSelectorImpl.init)

		container.register(AuthenticatorSelector.self, name: RegistrationAuthenticatorSelectorName) { res in
			AuthenticatorSelectorImpl(
				appCoordinator: res~>,
				configurationLoader: res~>,
				operation: .registration
			)
		}

		container.register(AuthenticatorSelector.self, name: AuthenticationAuthenticatorSelectorName) { res in
			AuthenticatorSelectorImpl(
				appCoordinator: res~>,
				configurationLoader: res~>,
				operation: .authentication
			)
		}

		container.autoregister(PinEnroller.self, initializer: PinEnrollerImpl.init)

		container.autoregister(PinChanger.self, initializer: PinChangerImpl.init)

		container.autoregister(PinUserVerifier.self, initializer: PinUserVerifierImpl.init)

		container.autoregister(PasswordEnroller.self, initializer: PasswordEnrollerImpl.init)

		container.autoregister(PasswordChanger.self, initializer: PasswordChangerImpl.init)

		container.autoregister(PasswordUserVerifier.self, initializer: PasswordUserVerifierImpl.init)

		container.autoregister(PasswordPolicy.self, initializer: PasswordPolicyImpl.init)

		container.autoregister(BiometricUserVerifier.self, initializer: BiometricUserVerifierImpl.init)

		container.autoregister(DevicePasscodeUserVerifier.self, initializer: DevicePasscodeUserVerifierImpl.init)

		container.autoregister(LoginService.self, initializer: LoginServiceImpl.init)

		container.registerOnMain(OutOfBandOperationHandler.self) { res in
			let authSelectorForReg = res ~> (AuthenticatorSelector.self, name: RegistrationAuthenticatorSelectorName)
			let authSelectorForAuth = res ~> (AuthenticatorSelector.self, name: AuthenticationAuthenticatorSelectorName)
			return OutOfBandOperationHandlerImpl(
				clientProvider: res~>,
				accountSelector: res~>,
				registrationAuthenticatorSelector: authSelectorForReg,
				authenticationAuthenticatorSelector: authSelectorForAuth,
				pinEnroller: res~>,
				pinUserVerifier: res~>,
				passwordEnroller: res~>,
				passwordUserVerifier: res~>,
				biometricUserVerifier: res~>,
				devicePasscodeUserVerifier: res~>,
				appCoordinator: res~>,
				errorHandlerChain: res~>
			)
		}
		.inObjectScope(.transient)

		container.autoregisterOnMain(
			ErrorHandler.self,
			name: NevisErrorHandlerName,
			initializer: NevisErrorHandler.init
		)

		container.autoregisterOnMain(
			ErrorHandler.self,
			name: GeneralErrorHandlerName,
			initializer: GeneralErrorHandler.init
		)

		container.registerOnMain(ErrorHandlerChain.self) { res in
			ErrorHandlerChainImpl(errorHandlers: [
				res ~> (ErrorHandler.self, name: NevisErrorHandlerName),
				res ~> (ErrorHandler.self, name: GeneralErrorHandlerName),
			])
		}
	}
}

// MARK: - Main Actor Registration

/// Swinject is not concurrency-aware: its factories are nonisolated. These helpers allow registering
/// `@MainActor`-isolated types. Resolution must happen on the main thread, otherwise it traps.
private extension Container {

	/// Wraps a value so it can cross into / out of the main actor; Swinject owns these values and resolves them on the main thread.
	struct UncheckedSendableBox<Value>: @unchecked Sendable {
		let value: Value
	}

	@discardableResult
	func registerOnMain<Service>(
		_ serviceType: Service.Type,
		name: String? = nil,
		factory: @escaping @MainActor (Resolver) -> Service
	) -> ServiceEntry<Service> {
		register(serviceType, name: name) { resolver in
			let resolver = UncheckedSendableBox(value: resolver)
			return MainActor.assumeIsolated {
				UncheckedSendableBox(value: factory(resolver.value))
			}.value
		}
	}

	@discardableResult
	func registerOnMain<Service, Argument>(
		_ serviceType: Service.Type,
		name: String? = nil,
		factory: @escaping @MainActor (Resolver, Argument) -> Service
	) -> ServiceEntry<Service> {
		register(serviceType, name: name) { (resolver: Resolver, argument: Argument) in
			let input = UncheckedSendableBox(value: (resolver, argument))
			return MainActor.assumeIsolated {
				UncheckedSendableBox(value: factory(input.value.0, input.value.1))
			}.value
		}
	}

	@discardableResult
	func autoregisterOnMain<Service, each Dependency>(
		_ serviceType: Service.Type,
		name: String? = nil,
		initializer: @escaping @MainActor (repeat each Dependency) -> Service
	) -> ServiceEntry<Service> {
		registerOnMain(serviceType, name: name) { resolver in
			initializer(repeat resolver ~> (each Dependency).self)
		}
	}

	// A variadic pack followed by the argument is not supported by the compiler, hence the explicit overloads.

	@discardableResult
	func autoregisterOnMain<Service, Argument>(
		_ serviceType: Service.Type,
		argument _: Argument.Type,
		initializer: @escaping @MainActor (Argument) -> Service
	) -> ServiceEntry<Service> {
		registerOnMain(serviceType) { (_: Resolver, argument: Argument) in
			initializer(argument)
		}
	}

	@discardableResult
	func autoregisterOnMain<Service, Argument, A>(
		_ serviceType: Service.Type,
		argument _: Argument.Type,
		initializer: @escaping @MainActor (A, Argument) -> Service
	) -> ServiceEntry<Service> {
		registerOnMain(serviceType) { (resolver: Resolver, argument: Argument) in
			initializer(resolver~>, argument)
		}
	}

	@discardableResult
	func autoregisterOnMain<Service, Argument, A, B>(
		_ serviceType: Service.Type,
		argument _: Argument.Type,
		initializer: @escaping @MainActor (A, B, Argument) -> Service
	) -> ServiceEntry<Service> {
		registerOnMain(serviceType) { (resolver: Resolver, argument: Argument) in
			initializer(resolver~>, resolver~>, argument)
		}
	}

	@discardableResult
	func autoregisterOnMain<Service, Argument, A, B, C>(
		_ serviceType: Service.Type,
		argument _: Argument.Type,
		initializer: @escaping @MainActor (A, B, C, Argument) -> Service
	) -> ServiceEntry<Service> {
		registerOnMain(serviceType) { (resolver: Resolver, argument: Argument) in
			initializer(resolver~>, resolver~>, resolver~>, argument)
		}
	}
}
