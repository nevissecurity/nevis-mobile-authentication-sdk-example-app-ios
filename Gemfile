source "https://rubygems.org"

# Cocoapods 1.15.1 does not download the SDK frameworks during `pod install`
gem 'cocoapods', '1.15.0'
gem 'fastlane'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
