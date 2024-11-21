import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mobility_plugin_platform_interface.dart';

/// An implementation of [MobilityPluginPlatform] that uses method channels.
class MethodChannelMobilityPlugin extends MobilityPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mobility_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
