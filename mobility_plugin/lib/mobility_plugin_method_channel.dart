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

  @override
  Future<Map<String, dynamic>> getMobilityData() async {
    try {
      final data = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getMobilityData');
      return data != null ? Map<String, dynamic>.from(data) : {};
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_GETTING_MOBILITY_DATA',
        message: 'Failed to get mobility data: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<void> requestAuthorization() async {
    try {
      await methodChannel.invokeMethod('requestAuthorization');
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_REQUESTING_AUTHORIZATION',
        message: 'Failed to request authorization: ${e.message}',
        details: e.details,
      );
    }
  }
}
