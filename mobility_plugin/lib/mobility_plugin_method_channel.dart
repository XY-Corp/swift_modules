import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mobility_plugin_platform_interface.dart';

/// An implementation of [MobilityPluginPlatform] that uses method channels.
class MethodChannelMobilityPlugin extends MobilityPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const methodChannel = MethodChannel('mobility_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<String, dynamic>> getAllMobilityData() async {
    try {
      final data = await methodChannel
          .invokeMethod<Map<dynamic, dynamic>>('getAllMobilityData');
      return data != null ? Map<String, dynamic>.from(data) : {};
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_GETTING_ALL_MOBILITY_DATA',
        message: 'Failed to get all mobility data: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getMobilityData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final data = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getMobilityData',
        {
          'startDate': startDate.millisecondsSinceEpoch,
          'endDate': endDate.millisecondsSinceEpoch,
        },
      );
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
  Future<Map<String, dynamic>> getRecentMobilityData({
    required int limit,
  }) async {
    try {
      final data = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getRecentMobilityData',
        {
          'limit': limit,
        },
      );
      return data != null ? Map<String, dynamic>.from(data) : {};
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_GETTING_RECENT_MOBILITY_DATA',
        message: 'Failed to get recent mobility data: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> requestAuthorization() async {
    try {
      // Because we expect a bool from the native side (true / false)
      final bool? success = await methodChannel.invokeMethod<bool>('requestAuthorization');
      // Return true if `success` from native is `true`, otherwise false
      return success == true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_REQUESTING_AUTHORIZATION',
        message: 'Failed to request authorization: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> hasMobilityPermissions() async {
    try {
      final bool? granted =
          await methodChannel.invokeMethod<bool>('hasMobilityPermissions');
      // Return true if native side returned true, otherwise false
      return granted == true;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_CHECKING_MOBILITY_PERMISSIONS',
        message: 'Failed to check mobility permissions: ${e.message}',
        details: e.details,
      );
    }
  }
  
  @override
  Future<Map<String, dynamic>> getMobilityDataByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final data = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getMobilityDataByType',
        {
          'type': type,
          'startDate': startDate.millisecondsSinceEpoch,
          'endDate': endDate.millisecondsSinceEpoch,
        },
      );
      return data != null ? Map<String, dynamic>.from(data) : {};
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_GETTING_MOBILITY_DATA_BY_TYPE',
        message: 'Failed to get mobility data by type: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMindfulnessData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final List<dynamic>? data = await methodChannel.invokeMethod<List<dynamic>>(
        'getMindfulnessData',
        {
          'startDate': startDate.millisecondsSinceEpoch,
          'endDate': endDate.millisecondsSinceEpoch,
        },
      );
      return data != null
          ? data.map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_GETTING_MINDFULNESS_DATA',
        message: 'Failed to get mindfulness data: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentMindfulnessData({
    required int limit,
  }) async {
    try {
      final List<dynamic>? data = await methodChannel.invokeMethod<List<dynamic>>(
        'getRecentMindfulnessData',
        {
          'limit': limit,
        },
      );
      return data != null
          ? data.map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
    } on PlatformException catch (e) {
      throw PlatformException(
        code: 'ERROR_GETTING_RECENT_MINDFULNESS_DATA',
        message: 'Failed to get recent mindfulness data: ${e.message}',
        details: e.details,
      );
    }
  }
}
