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

	/// Registers the screens.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerScreens(container: Container) {
		container.autoregister(LaunchScreen.self,
		                       initializer: LaunchScreen.init)
			.inObjectScope(.weak)

		container.autoregister(HomeScreen.self,
		                       initializer: HomeScreen.init)
			.inObjectScope(.weak)

		container.autoregister(QrScannerScreen.self,
		                       initializer: QrScannerScreen.init)
			.inObjectScope(.weak)

		container.register(ChangeDeviceInformationScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			ChangeDeviceInformationScreen(presenter: res ~> (ChangeDeviceInformationPresenter.self,
			                                                 argument: arg))
		}.inObjectScope(.weak)

		container.autoregister(AuthCloudApiRegistrationScreen.self,
		                       initializer: AuthCloudApiRegistrationScreen.init)
			.inObjectScope(.weak)

		container.autoregister(UsernamePasswordLoginScreen.self,
		                       initializer: UsernamePasswordLoginScreen.init)
			.inObjectScope(.weak)

		container.register(SelectAccountScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			SelectAccountScreen(presenter: res ~> (SelectAccountPresenter.self,
			                                       argument: arg))
		}.inObjectScope(.weak)

		container.register(SelectAuthenticatorScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			SelectAuthenticatorScreen(presenter: res ~> (SelectAuthenticatorPresenter.self,
			                                             argument: arg))
		}.inObjectScope(.weak)

		container.register(PinScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			PinScreen(presenter: res ~> (PinPresenter.self, argument: arg))
		}.inObjectScope(.weak)

		container.register(TransactionConfirmationScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			TransactionConfirmationScreen(presenter: res ~> (TransactionConfirmationPresenter.self,
			                                                 argument: arg))
		}.inObjectScope(.weak)

		container.register(ResultScreen.self) { (res: Resolver, arg: NavigationParameterizable) in
			ResultScreen(presenter: res ~> (ResultPresenter.self,
			                                argument: arg))
		}.inObjectScope(.weak)

		container.autoregister(NotEnrolledAuthenticatorScreen.self,
		                       initializer: NotEnrolledAuthenticatorScreen.init)
			.inObjectScope(.weak)

		container.autoregister(LoggingScreen.self,
		                       initializer: LoggingScreen.init)
			.inObjectScope(.container)
	}

	/// Registers the coordinators.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerCoordinators(container: Container) {
		container.autoregister(AppCoordinator.self,
		                       initializer: AppCoordinatorImpl.init)
			.inObjectScope(.container)
	}

	/// Registers the presenters.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerPresenters(container: Container) {
		container.autoregister(LaunchPresenter.self,
		                       initializer: LaunchPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(HomePresenter.self,
		                       initializer: HomePresenter.init)
			.inObjectScope(.transient)

		container.autoregister(QrScannerPresenter.self,
		                       initializer: QrScannerPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(ChangeDeviceInformationPresenter.self,
		                       argument: NavigationParameterizable.self,
		                       initializer: ChangeDeviceInformationPresenter.init)
			.inObjectScope(.transient)

		container.register(AuthCloudApiRegistrationPresenter.self) { res in
			let authenticatorSelector = res ~> (AuthenticatorSelector.self,
			                                    name: RegistrationAuthenticatorSelectorName)
			return AuthCloudApiRegistrationPresenter(clientProvider: res~>,
			                                         authenticatorSelector: authenticatorSelector,
			                                         pinEnroller: res~>,
			                                         biometricUserVerifier: res~>,
			                                         appCoordinator: res~>,
			                                         errorHandlerChain: res~>,
			                                         logger: res~>)
		}.inObjectScope(.transient)

		container.register(UsernamePasswordLoginPresenter.self) { res in
			let authenticatorSelector = res ~> (AuthenticatorSelector.self,
			                                    name: RegistrationAuthenticatorSelectorName)
			return UsernamePasswordLoginPresenter(configurationLoader: res~>,
			                                      loginService: res~>,
			                                      clientProvider: res~>,
			                                      authenticatorSelector: authenticatorSelector,
			                                      pinEnroller: res~>,
			                                      biometricUserVerifier: res~>,
			                                      appCoordinator: res~>,
			                                      errorHandlerChain: res~>,
			                                      logger: res~>)
		}.inObjectScope(.transient)

		container.register(SelectAccountPresenter.self) { res, arg in
			let authenticatorSelector = res ~> (AuthenticatorSelector.self,
			                                    name: AuthenticationAuthenticatorSelectorName)
			return SelectAccountPresenter(clientProvider: res~>,
			                              authenticatorSelector: authenticatorSelector,
			                              pinChanger: res~>,
			                              pinUserVerifier: res~>,
			                              biometricUserVerifier: res~>,
			                              appCoordinator: res~>,
			                              errorHandlerChain: res~>,
			                              logger: res~>,
			                              parameter: arg)
		}.inObjectScope(.transient)

		container.autoregister(SelectAuthenticatorPresenter.self,
		                       argument: NavigationParameterizable.self,
		                       initializer: SelectAuthenticatorPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(PinPresenter.self,
		                       argument: NavigationParameterizable.self,
		                       initializer: PinPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(TransactionConfirmationPresenter.self,
		                       argument: NavigationParameterizable.self,
		                       initializer: TransactionConfirmationPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(ResultPresenter.self,
		                       argument: NavigationParameterizable.self,
		                       initializer: ResultPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(NotEnrolledAuthenticatorPresenter.self,
		                       initializer: NotEnrolledAuthenticatorPresenter.init)
			.inObjectScope(.transient)

		container.autoregister(LoggingPresenter.self,
		                       initializer: LoggingPresenter.init)
			.inObjectScope(.transient)
	}

	/// Registers the components.
	///
	/// - Parameter container: The container provided by the `Assembler`.
	func registerComponents(container: Container) {
		container.register(ConfigurationLoader.self) { _ in
			ConfigurationLoaderImpl(environment: .authenticationCloud)
		}

		container.autoregister(ClientProvider.self,
		                       initializer: ClientProviderImpl.init)
			.inObjectScope(.container)

		container.autoregister(AccountSelector.self,
		                       initializer: AccountSelectorImpl.init)

		container.autoregister(AuthenticatorSelector.self,
		                       name: AuthenticationAuthenticatorSelectorName,
		                       initializer: AuthenticationAuthenticatorSelectorImpl.init)

		container.autoregister(AuthenticatorSelector.self,
		                       name: RegistrationAuthenticatorSelectorName,
		                       initializer: RegistrationAuthenticatorSelectorImpl.init)

		container.autoregister(PinEnroller.self,
		                       initializer: PinEnrollerImpl.init)

		container.autoregister(PinChanger.self,
		                       initializer: PinChangerImpl.init)

		container.autoregister(PinUserVerifier.self,
		                       initializer: PinUserVerifierImpl.init)

		container.autoregister(BiometricUserVerifier.self,
		                       initializer: BiometricUserVerifierImpl.init)

		container.autoregister(LoginService.self,
		                       initializer: LoginServiceImpl.init)

		container.autoregister(SDKLogger.self,
		                       initializer: SDKLoggerImpl.init)
			.inObjectScope(.container)

		container.register(OutOfBandOperationHandler.self) { res in
			let authSelectorForReg = res ~> (AuthenticatorSelector.self,
			                                 name: RegistrationAuthenticatorSelectorName)
			let authSelectorForAuth = res ~> (AuthenticatorSelector.self,
			                                  name: AuthenticationAuthenticatorSelectorName)
			return OutOfBandOperationHandlerImpl(clientProvider: res~>,
			                                     accountSelector: res~>,
			                                     registrationAuthenticatorSelector: authSelectorForReg,
			                                     authenticationAuthenticatorSelector: authSelectorForAuth,
			                                     pinEnroller: res~>,
			                                     pinUserVerifier: res~>,
			                                     biometricUserVerifier: res~>,
			                                     appCoordinator: res~>,
			                                     errorHandlerChain: res~>,
			                                     logger: res~>)
		}
		.inObjectScope(.transient)

		container.autoregister(ErrorHandler.self,
		                       name: NevisErrorHandlerName,
		                       initializer: NevisErrorHandler.init)

		container.autoregister(ErrorHandler.self,
		                       name: GeneralErrorHandlerName,
		                       initializer: GeneralErrorHandler.init)

		container.register(ErrorHandlerChain.self) { res in
			ErrorHandlerChainImpl(errorHandlers: [res ~> (ErrorHandler.self, name: NevisErrorHandlerName),
			                                      res ~> (ErrorHandler.self, name: GeneralErrorHandlerName)])
		}
	}
}
