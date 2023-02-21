![Nevis Logo](https://www.nevis.net/hubfs/Nevis/images/logotype.svg)

# Nevis Mobile Authentication SDK iOS Example App

[![Main Branch Commit](https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-ios/actions/workflows/main.yml/badge.svg)](https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-ios/actions/workflows/main.yml)
[![Verify Pull Request](https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-ios/actions/workflows/pr.yml/badge.svg)](https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-ios/actions/workflows/pr.yml)

This repository contains the example app demonstrating how to use the Nevis Mobile Authentication SDK in an iOS mobile application.
The Nevis Mobile Authentication SDK allows you to integrate passwordless authentication to your existing mobile app, backed by the FIDO UAF 1.1 Standard.

Some SDK features demonstrated in this example app are:

* Using the SDK with the Nevis Authentication Cloud
* Registering with QR code & app link URIs
* Simulating in-band authentication after registration
* Deregistering a registered account
* Changing the PIN of the PIN authenticator
* Changing the device information

Please note that the example app only demonstrates a subset of the available SDK features. The main purpose is to demonstrate how the SDK can be used, not to cover all supported scenarios.

## Getting Started

Before you start compiling and using the example applications please ensure you have the following ready:

* An [Authentication Cloud](https://docs.nevis.net/authcloud/) instance provided by Nevis.
* An [access key](https://docs.nevis.net/authcloud/access-app/access-key) to use with the Authentication Cloud.

Your development setup has to meet the following prerequisites:

* iOS 12 or later
* Xcode 14.1, including Swift 5.7

### Initialization

Dependencies in this project are provided via Cocoapods. Please install all dependencies by running

`
pod install
`

### Configuration

Before being able to use the example app with your Authentication Cloud instance, you'll need to update the configuration file with the right host information.

Edit the [ConfigAuthenticationCloud.plist](NevisExampleApp/Resources/ConfigAuthenticationCloud.plist) file and replace the host name information with your Authentication Cloud instance.

#### Configuration Change

The example apps are supporting two kinds of configuration: `authenticationCloud` and `identitySuite`.

> **_NOTE_**  
> Only *build-time* configuration change is supported.

To change the configuration open the [AppAssembly.swift](NevisExampleApp/Dependency%20Provider/AppAssembly.swift) file which describes the dependency injection related configuration using the `Swinject` library.
The `environment` parameter should be changed when injecting the `ConfigurationLoaderImpl` component to one of the values already mentioned.

### Build & run

Now you're ready to build and run the example app by choosing Product > Run from Xcode's menu or by clicking the Run button in your project’s toolbar.

> **_NOTE_**  
> Running the app on an iOS device requires codesign setup.

### Try it out

Now that the iOS example app is up and running, it's time to try it out!

Check out our [Quickstart Guide](https://docs.nevis.net/mobilesdk/quickstart).

## Integration Notes

In this section you can find hints about how the Nevis Mobile Authentication SDK is integrated into the example app.

* All SDK invocation is implemented in the corresponding presenter class.
* All SDK specific user interaction related protocol implementation can be found in the [Interaction](NevisExampleApp/Interaction) folder.

### Initialization

The [HomePresenter](NevisExampleApp/Screens/Home/HomePresenter.swift) class is responsible for creating and initializing a `MobileAuthenticationClient` instance which is the entry point to the SDK. Later this instance can be used to start the different operations.

### Registration

Before being able to authenticate using the Nevis Mobile Authentication SDK, go through the registration process. Depending on the use case, there are two types of registration: [in-app registration](#in-app-registration) and [out-of-band registration](#out-of-band-registration).

#### In-app registration

If the application is using a backend using the Nevis Authentication Cloud, the [AuthCloudApiRegistrationPresenter](NevisExampleApp/Screens/Auth%20Cloud%20Api%20Registration/AuthCloudApiRegistrationPresenter.swift) class will be used by passing the `enrollment` response or an `appLinkUri`.

When the backend used by the application does not use the Nevis Authentication Cloud the name of the user to be registered is passed to the [LegacyLoginPresenter](NevisExampleApp/Screens/Legacy%20Login/LegacyLoginPresenter.swift) class.
If authorization is required by the backend to register, provide an `AuthorizationProvider`. In the example app a `CookieAuthorizationProvider` is created from the cookies (see [LegacyLoginPresenter](NevisExampleApp/Screens/Legacy%20Login/LegacyLoginPresenter.swift)) obtained by the [LoginServiceImpl](NevisExampleApp/Utility/Login/LoginServiceImpl.swift) class.

#### Out-of-band registration

When the registration is initiated in another device or application, the information required to process the operation is transmitted through a QR code or a link. After the payload obtained from the QR code or the link is decoded the  [OutOfBandOperationHandlerImpl](NevisExampleApp/Interaction/OutOfBandOperationHandlerImpl.swift) class starts the out-of-band operation.

### Authentication

Using the authentication operation, you can verify the identity of the user using an already registered authenticator. Depending on the use case, there are two types of authentication: [in-app authentication](#in-app-authentication) and [out-of-band authentication](#out-of-band-authentication).

#### In-app authentication

For the application to trigger the authentication, the name of the user is provided to the [SelectAccountPresenter](NevisExampleApp/Screens/Select%20Account/SelectAccountPresenter.swift) class.

#### Out-of-band authentication

When the authentication is initiated in another device or application, the information required to process the operation is transmitted through a QR code or a link. After the payload obtained from the QR code or the link is decoded the  [OutOfBandOperationHandlerImpl](NevisExampleApp/Interaction/OutOfBandOperationHandlerImpl.swift) class starts the out-of-band operation.

#### Transaction confirmation

There are cases when specific information is to be presented to the user during the user verification process, known as transaction confirmation. The `AuthenticatorSelectionContext` and the `AccountSelectionContext` contain a byte array with the information. In the example app it is handled in the [AccountSelectorImpl](NevisExampleApp/Interaction/AccountSelectorImpl.swift) class.

### Deregistration

The [HomePresenter](NevisExampleApp/Screens/Home/HomePresenter.swift) class is responsible for deregistering either a user or all of the registered users from the device.

### Other operations

#### Change PIN

With the change PIN operation you can modify the PIN of a registered PIN authenticator for a given user. It is implemented in:
* in case of a single registered user see the [HomePresenter](NevisExampleApp/Screens/Home/HomePresenter.swift) class.
* in case of multiple registered users see the [SelectAccountPresenter](NevisExampleApp/Screens/Select%20Account/SelectAccountPresenter.swift) class.

#### Decode out-of-band payload

Out-of-band operations occur when a message is delivered to the application through an alternate channel like a push notification, a QR code, or a deep link. With the help of the [OutOfBandOperationHandlerImpl](NevisExampleApp/Interaction/OutOfBandOperationHandlerImpl.swift) class the application can create an `OutOfBandPayload` either from a JSON or a Base64 URL encoded String. The `OutOfBandPayload` is then used to start an `OutOfBandOperation`, see chapters [Out-of-Band Registration](#out-of-band-registration) and [Out-of-Band Authentication](#out-of-band-authentication).

#### Change device information

During registration, the device information can be provided that contains the name identifying your device, and also the Firebase Cloud Messaging registration token. Updating both the name and the token is implemented in the [ChangeDeviceInformationPresenter](NevisExampleApp/Screens/Change%20Device%20Information/ChangeDeviceInformationPresenter.swift) class.

© 2023 made with ❤ by Nevis
