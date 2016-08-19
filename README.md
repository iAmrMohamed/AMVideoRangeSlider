AMVideoRangeSlider
============

iOS Video Range Slider in Swift

![amvideorangeslider](https://cloud.githubusercontent.com/assets/8356318/17717975/9cac9d66-6411-11e6-8ce5-2e0a9b0f479b.gif)

### Code

```swift
let videoRangeSlider = AMVideoRangeSlider(frame: CGRectMake(16, 16, 300, 20))
let url = NSBundle.mainBundle().URLForResource("video", withExtension: "mp4")
videoRangeSlider.videoAsset = AVAsset(URL: url!)
videoRangeSlider.delegate = self
```

### Delegate Methods

```swift
func rangeSliderLowerThumbValueChanged() {
    print(self.videoRangeSlider.startTime.seconds)
}

func rangeSliderMiddleThumbValueChanged() {
    print(self.videoRangeSlider.currentTime.seconds)
}

func rangeSliderUpperThumbValueChanged() {
    print(self.videoRangeSlider.stopTime.seconds)
}
```

## Installation

### CocoaPods

You can install the latest release version of CocoaPods with the following command:

```bash
$ gem install cocoapods
```

*CocoaPods v0.36 or later required*

Simply add the following line to your Podfile:

```ruby
platform :ios, '8.0' 
use_frameworks!

pod 'AMVideoRangeSlider', :git => 'https://github.com/iAmrMohamed/AMVideoRangeSlider.git' 
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate AMVideoRangeSlider into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "iAmrMohamed/AMVideoRangeSlider"
```

## Requirements

- iOS 8.0+
- Xcode 7.3+

## License

AMVideoRangeSlider is released under the MIT license. See LICENSE for details.
