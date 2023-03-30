workspace 'NevisExampleApp'
project 'NevisExampleApp.xcodeproj'

use_frameworks!

IOSDeploymentTarget = '12.0'

target 'NevisExampleApp' do
	platform :ios, IOSDeploymentTarget

	pod 'FittedSheets', '= 2.4.2'
	pod 'KRProgressHUD', '= 3.4.7'
	pod 'MercariQRScanner', '= 1.9.0'
	pod 'Swinject', '= 2.7.1'
	pod 'SwinjectAutoregistration', '= 2.8.1'
	pod 'Then', '= 3.0.0'
	pod 'NevisMobileAuthentication', '~> 3.2.0', :configurations => ['Release']
	pod 'NevisMobileAuthentication-Debug', '~> 3.2.0', :configurations => ['Debug']
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = IOSDeploymentTarget
			config.build_settings['ENABLE_BITCODE'] = 'NO' # NMA SDK does not support Bitcode
		end
	end
end
