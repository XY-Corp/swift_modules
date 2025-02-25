# Mobility Plugin

A Flutter plugin to access mobility data from Apple HealthKit, including walking speed, step length, and other mobility metrics.

## Overview

The Mobility Plugin provides a simple and unified way to access mobility-related data from Apple HealthKit within your Flutter applications. This plugin allows you to:

- Fetch various mobility metrics such as walking speed, step length, double support percentage, asymmetry percentage, and walking steadiness.
- Retrieve mobility data for specific date ranges.
- Obtain recent mobility data with a specified limit.
- Request user authorization to access HealthKit data.

## Folder Structure

- `lib`
- `ios`
- `example`

### lib

This directory contains the Dart code for the plugin.

- `mobility_plugin.dart`: The main class that exposes the plugin's functionalities to the Flutter app. It defines methods to interact with the platform-specific implementation.
- `mobility_plugin_method_channel.dart`: Implements the platform-specific code using Flutter's method channels. It communicates with the native code (Swift for iOS) to perform the required operations.
- `mobility_plugin_platform_interface.dart`: Defines the abstract class that sets the contract for the platform-specific implementations. This ensures consistency across different platforms.

### ios

Contains the iOS-specific implementation of the plugin using Swift and Objective-C.

#### Classes:

- `MobilityPlugin.swift`: The core of the iOS implementation. It interacts with Apple's HealthKit framework to access mobility data. Key functionalities include:
  - Handling method calls from Dart and executing corresponding native code.
  - Requesting authorization from the user to access HealthKit data.
  - Fetching various mobility metrics and returning them to the Flutter app.
- `MobilityPlugin.h` and `MobilityPlugin.m`: Objective-C bridge files that facilitate the communication between Flutter and Swift code.

#### Resources:

- `PrivacyInfo.xcprivacy`: A privacy configuration file required by Xcode to specify how the app handles user data.
- `mobility_plugin.podspec`: The CocoaPods specification file that describes the plugin's iOS dependencies and configurations. It defines the plugin's name, version, source files, and other metadata.

### example

An example Flutter application demonstrating how to use the Mobility Plugin. This is a practical reference to help you integrate the plugin into your own projects.

#### Running the Example

To run the example application, follow these steps:

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/XY-Corp/swift_modules.git
   cd swift_modules/example
   ```

2. Navigate to the `example` directory of the `mobility_plugin`:

   ```bash
   cd mobility_plugin/example
   ```

3. Get the dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app on an emulator or connected device:

   ```bash
   flutter run
   ```

#### lib:

- `main.dart`: The main entry point of the example app. It showcases how to:
  - Initialize and use the MobilityPlugin class.
  - Request authorization to access HealthKit data.
  - Fetch and display mobility metrics in the app's UI.

#### ios:

- `Runner`: Contains iOS-specific files for the example app.
- `AppDelegate.swift`: The application delegate for the iOS app.
- `Assets.xcassets`: App icons and launch images.
- `Base.lproj`: Storyboard files for app launch screens.
- `GeneratedPluginRegistrant.`: Files that register the plugin with the Flutter engine.
- `Runner.entitlements`: Specifies app capabilities and permissions.

#### integration_test:

- `plugin_integration_test.dart`: Integration tests for the plugin to ensure it works as expected within an app.

## Getting Started

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  mobility_plugin:
    git:
      url: url: https://github.com/XY-Corp/swift_modules.git
```

Run `flutter pub get` to fetch the plugin.

### Usage

Import the plugin in your Dart code:

```dart
import 'package:mobility_plugin/mobility_plugin.dart';
```

Initialize the Plugin:

```dart
final MobilityPlugin mobilityPlugin = MobilityPlugin();
```

### Request Authorization

Before accessing HealthKit data, you must request authorization:

```dart
await mobilityPlugin.requestAuthorization();
```

### Supported Mobility Metrics

- Walking Speed (WALKING_SPEED)
- Step Length (STEP_LENGTH)
- Double Support Percentage (DOUBLE_SUPPORT_PERCENTAGE)
- Asymmetry Percentage (ASYMMETRY_PERCENTAGE) (iOS 15 and above)
- Walking Steadiness (WALKING_STEADINESS) (iOS 15 and above)

### Permissions

In your app ensure you have included the necessary permissions in your `Info.plist` (iOS):

```xml
<key>NSHealthShareUsageDescription</key>
<string>Need access to health data for mobility metrics.</string>
```

<p align="center">
  <img src="https://github.com/user-attachments/assets/636daf97-fb05-43e4-b22d-c629b9c02200" width="45%">
  <img src="https://github.com/user-attachments/assets/929ad073-9aac-47d8-a161-b99c5aa0d30b" width="45%">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/cbe15bbb-e8b0-4aa3-a734-154124eda6b2" width="45%">
  <img src="https://github.com/user-attachments/assets/b969294e-4b98-460a-b2c7-174060349fdc" width="45%">
</p>
