# ``NevisExampleApp``

An example application demonstrating how to use the Nevis Mobile Authentication SDK in an iOS mobile application.

## Overview

The Nevis Mobile Authentication SDK allows you to integrate passwordless authentication to your existing mobile app, backed by the FIDO UAF 1.1 Standard.

Some SDK features demonstrated in this example app are:

* Using the SDK with the Nevis Authentication Cloud
* Registering with QR code & app link URIs
* Simulating in-band authentication after registration
* Deregistering a registered account
* Changing the PIN of the PIN authenticator
* Changing the device information

Please note that the example app only demonstrates a subset of the available SDK features. The main purpose is to demonstrate how the SDK can be used, not to cover all supported scenarios.

## Topics

### Application

- ``AppDelegate``

### Configuration

- ``ConfigurationLoader``
- ``ConfigurationLoaderImpl``
- ``AppConfiguration``
- ``LoginConfiguration``
- ``Environment``

### Coordinator

- ``Coordinator``
- ``NavigationParameterizable``
- ``AppCoordinator``
- ``AppCoordinatorImpl``

### Dependency Provider

- ``AppAssembly``
- ``DependencyProvider``

### Error

- ``AppError``
- ``ErrorHandlerChain``
- ``ErrorHandlerChainImpl``
- ``ErrorHandler``
- ``GeneralErrorHandlerName``
- ``GeneralErrorHandler``
- ``NevisErrorHandlerName``
- ``NevisErrorHandler``

### Interaction

- ``AccountSelectorImpl``
- ``AuthenticatorSelectorImpl``
- ``AuthenticationAuthenticatorSelectorName``
- ``BiometricUserVerifierImpl``
- ``DevicePasscodeUserVerifierImpl``
- ``OutOfBandOperationHandler``
- ``OutOfBandOperationHandlerImpl``
- ``PinChangerImpl``
- ``PinEnrollerImpl``
- ``PinUserVerifierImpl``
- ``PasswordChangerImpl``
- ``PasswordEnrollerImpl``
- ``PasswordUserVerifierImpl``
- ``RegistrationAuthenticatorSelectorName``

### Model

- ``AuthenticatorItem``
- ``DeepLink``
- ``Operation``
- ``OperationError``

### Screens

- ``Screen``
- ``BaseScreen``
- ``BaseView``
- ``LaunchScreen``
- ``LaunchPresenter``
- ``HomeScreen``
- ``HomePresenter``
- ``QrScannerScreen``
- ``QrScannerPresenter``
- ``SelectAccountScreen``
- ``SelectAccountPresenter``
- ``SelectAccountParameter``
- ``SelectAccountItemViewModel``
- ``AccountCell``
- ``SelectAuthenticatorScreen``
- ``SelectAuthenticatorPresenter``
- ``SelectAuthenticatorParameter``
- ``SelectAuthenticatorItemViewModel``
- ``AuthenticatorCell``
- ``CredentialScreen``
- ``CredentialView``
- ``CredentialPresenter``
- ``CredentialParameter``
- ``PinParameter``
- ``PasswordParameter``
- ``CredentialProtectionInformation``
- ``AuthCloudApiRegistrationScreen``
- ``AuthCloudApiRegistrationPresenter``
- ``ChangeDeviceInformationScreen``
- ``ChangeDeviceInformationPresenter``
- ``ChangeDeviceInformationParameter``
- ``UsernamePasswordLoginScreen``
- ``UsernamePasswordLoginPresenter``
- ``TransactionConfirmationScreen``
- ``TransactionConfirmationPresenter``
- ``TransactionConfirmationParameter``
- ``ConfirmationScreen``
- ``ConfirmationPresenter``
- ``ConfirmationParameter``
- ``ResultScreen``
- ``ResultPresenter``
- ``ResultParameter``
- ``LoggingScreen``
- ``LoggingView``
- ``LoggingPresenter``

### Client Provider

- ``ClientProvider``
- ``ClientProviderImpl``

### Timer

- ``InteractionCountDownTimer``

### Localization

- ``L10n``

### Logger

- ``Logger``

### Login

- ``LoginService``
- ``LoginServiceImpl``
- ``LoginSessionDelegate``
- ``LoginRequest``
- ``LoginResponse``

### UI

- ``NSLabel``
- ``NSTextField``
- ``OutlinedButton``
- ``Style``

### Validation

- ``AccountValidator``
- ``AuthenticatorValidator``
- ``AuthCloudApiRegistrationValidator``
- ``LoginValidator``
- ``ValidationResult``
- ``PasswordPolicyImpl``
- ``PasswordPolicyError``
