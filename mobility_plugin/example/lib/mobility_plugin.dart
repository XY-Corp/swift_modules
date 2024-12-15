import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mobility_plugin/mobility_plugin_platform_interface.dart';

class MobilityPlugin {
  static final MobilityPluginPlatform _platform = MobilityPluginPlatform.instance;

  Future<String?> getPlatformVersion() async {
    try {
      return await _platform.getPlatformVersion();
    } on PlatformException catch (e) {
      throw 'Failed to get platform version: ${e.message}';
    }
  }

  Future<void> requestAuthorization() async {
    try {
      await _platform.requestAuthorization();
    } on PlatformException catch (e) {
      throw 'Failed to request authorization: ${e.message}';
    }
  }

  Future<Map<String, dynamic>> getMobilityData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _platform.getMobilityData(
        startDate: startDate,
        endDate: endDate,
      );
    } on PlatformException catch (e) {
      throw 'Failed to get mobility data: ${e.message}';
    }
  }

  /// Fetches mindfulness data within a date range.
  Future<List<Map<String, dynamic>>> getMindfulnessData({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _platform.getMindfulnessData(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Fetches recent mindfulness data with a limit.
  Future<List<Map<String, dynamic>>> getRecentMindfulnessData({
    required int limit,
  }) {
    return _platform.getRecentMindfulnessData(limit: limit);
  }
}