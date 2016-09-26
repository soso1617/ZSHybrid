# ZSHybrid

[![CI Status](http://img.shields.io/travis/SoSo/ZSHybrid.svg?style=flat)](https://travis-ci.org/SoSo/ZSHybrid)
[![Version](https://img.shields.io/cocoapods/v/ZSHybrid.svg?style=flat)](http://cocoapods.org/pods/ZSHybrid)
[![License](https://img.shields.io/cocoapods/l/ZSHybrid.svg?style=flat)](http://cocoapods.org/pods/ZSHybrid)
[![Platform](https://img.shields.io/cocoapods/p/ZSHybrid.svg?style=flat)](http://cocoapods.org/pods/ZSHybrid)

A lightweight hybrid framework. Simplified to integrate in every iOS project with little efforts, no anyother dependencies, please enjoy!

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ZSHybrid is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZSHybrid', :git => 'git@github.com:soso1617/ZSHybrid.git'
```

## Usage

### iOS

ZSHyScenarioManager

Create your won scenario wich inherited from ZSHyScenarioManager, implement [Title] and [webPageURLString]. After that, you could call [loadScenarioFromViewController:openMode:] directly to open a webview with viewcontroller from your views.

ZSHyOperationDelegate

Once you have created your own scenario manager, you need to confirm this protocol for receive message and handle it from webview. Override [registerOperationsNames] to provide a bunch of [command names] which you want to handle from webview. Override [handleOperation:] to handle the operation from webview with parameters.

ZSHyOperation

The ZSHyOperation object contains the information from webview, and you could get parameters from it as well. And when you need send message back to webview, you need to send this object back as well. Please see the class "SampleManagerA" for more details.

### JavaScript (ZSHybrid.js)

Any webview need to implement hybrid solution need to ref this JS file. It provide very simple interfaces for web page to send and receive message with mobile native client. There is only one interface for web page: invokeMobileWithCallbackFunctions(...), send your [command name] (which should be registered in "ZSHyOperationDelegate" method), parameters (you can send both JSON string and post form string to mobile native client with isJSON flag), and successful callback and failed callback to handle the next steps after received callback string from mobile native client.

Please find ZSHybrid.js in example code additionally, the js file haven't been provided in pod framework yet.

### Register URL Scheme

Another important thing is that you may need to set your own scheme for url interception. You could have multi-schemes to interception in one application if you need at any time. And for each web page, you could set corresponding scheme as well.

```objc
[[ZSHyOperationCenter defaultCenter] registerHybridScheme:@[@"hybridsample"]];
```

```js
zshybrid.registerSchemeForApplication("hybridsample");
```


## Author

SoSo, eric_roger1137@hotmail.com

## License

ZSHybrid is available under the MIT license. See the LICENSE file for more info.
