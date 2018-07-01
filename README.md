# AppConfigSwift

[![CI Status](http://img.shields.io/travis/crescentflare/AppConfigSwift.svg?style=flat)](https://travis-ci.org/crescentflare/AppConfigSwift)
[![Version](https://img.shields.io/cocoapods/v/AppConfigSwift.svg?style=flat)](http://cocoapods.org/pods/AppConfigSwift)
[![License](https://img.shields.io/cocoapods/l/AppConfigSwift.svg?style=flat)](http://cocoapods.org/pods/AppConfigSwift)
[![Platform](https://img.shields.io/cocoapods/p/AppConfigSwift.svg?style=flat)](http://cocoapods.org/pods/AppConfigSwift)

A useful library to support multiple build configurations or global settings in one application build.

For example: be able to make one build with a build selector that contains development, test, acceptance and a production configuration. There would be no need to deliver multiple builds for each environment for testing, it can all be done from one build.


### Features

- Be able to configure several app configurations using a plist file
- A built-in app configuration selection menu
- Edit app configurations to customize them from within the app
- Easily access the currently selected configuration (or last stored selection) everywhere
- Separate global settings which work across different configurations
- Be able to write custom plugins, like development tools, making them accessible through the selection menu
- Dynamic configurations can be disabled to prevent them from being available on distribution (App Store) builds


### Integration guide

The library is available through [CocoaPods](http://cocoapods.org). To install it, simply add one of the following lines to your Podfile.

```ruby
pod "AppConfigSwift", '~> 1.1.1'
```

The above version is for Swift 4.1. For older Swift versions use the following:
- Swift 4.0: AppConfigSwift 1.1.0
- Swift 3: AppConfigSwift 0.7.2
- Swift 2.2: AppConfigSwift 0.7.0


### Storage

When existing configurations are edited or custom ones are being added, the changes are saved in the user defaults storage of the device. Also the last selected configuration and global settings are stored inside userdefaults. This makes sure that it remembers the correct settings, even if the app is restarted.


### Security

Because the library can give a lot of control on the product (by making its settings configurable), it's important to prevent any code (either the selection menu itself, or the plist configuration data like test servers and passwords) from being deployed to the App Store. Take a look at the example project for more information. For the release configuration it doesn't activate the app config and excludes the plist file from the build (by adding it to excluded source file names in the build settings).


### Example

The provided example shows how to set up a configuration model, define configuration settings and launch the configuration tool. It also includes a demo of using global settings and a custom logging tool.


### Status

The library is stable and has been used in many projects. New features may be added in the future.
