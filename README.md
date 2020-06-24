# dashcast-gb
A podcast app from The Boring Flutter Development show.


# Installation

## flutter_sound
Adding [flutter_sound](https://pub.dev/packages/flutter_sound) can be a time consuming experience. Follow the steps below to make installing it to your app a breeze:

In your `pubspec.yaml`, add dependency:
`flutter_sound_lite: ^4.0.0`

In `/ios/Podfile` make the following changes:
Uncomment line which looks like this: `platform :ios, 'x.x'`
Since `flutter_sound` supports iOS 9.3 and above, change the line to read: `platform :ios, '9.3'`

Now in terminal, from your project root directory, run the following, ensuring that each step completes successfully:
`pod repo update`
`gem install cocoapods`
`pod setup`

Finally, run the app, which should run `pod install` as part of the launch.