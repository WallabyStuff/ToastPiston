# ToastPiston

[![CI Status](https://img.shields.io/travis/WallabyStuff/ToastPiston.svg?style=flat)](https://travis-ci.org/WallabyStuff/ToastPiston)
![Static Badge](https://img.shields.io/badge/spm-blue)
[![Version](https://img.shields.io/cocoapods/v/ToastPiston.svg?style=flat)](https://cocoapods.org/pods/ToastPiston)
[![License](https://img.shields.io/cocoapods/l/ToastPiston.svg?style=flat)](https://cocoapods.org/pods/ToastPiston)
[![Platform](https://img.shields.io/cocoapods/p/ToastPiston.svg?style=flat)](https://cocoapods.org/pods/ToastPiston)


<br>
<br>

# Preview
<img src="https://github.com/WallabyStuff/ToastPiston/assets/63496607/61b02b11-fb25-492b-b5d0-7ca6a3a196a8"/>

<br>
<br>

# Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
class YourViewController: UIViewController {
  ...
  
  showPistonToast(title: "Your toast message")

  ...
}
```

<br>

## Parameters
### title
**required** <br>
type: ```String``` <br>

### titleColor
type: ```UIColor``` <br>
default: ```UIColor.white```

### font
type: ```UIFont``` <br>
default: ```UIFont.systemFont(ofSize: 15, weight: .semibold)```

### blurStyle 
type: ```UIBlurEffect.Style``` <br>
default: ```UIBlurEffect.Style.dark```

<br>
<br>

# Requirements
- iOS 13.0+

<br>
<br>

# Installation

ToastPiston is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ToastPiston'
```

<br>
<br>

# Author

WallabyStuff, avocado34.131@gmail.com

<br>

# License

ToastPiston is available under the MIT license. See the LICENSE file for more info.
