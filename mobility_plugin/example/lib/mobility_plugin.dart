import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mobility_plugin/mobility_plugin_platform_interface.dart';

class MobilityPlugin {
  static final MobilityPluginPlatform _platform =
      MobilityPluginPlatform.instance;

  Future<String?> getPlatformVersion() async {
    try {
      return await _platform.getPlatformVersion();
    } on PlatformException catch (e) {
      throw 'Failed to get platform version: ${e.message}';
    }
  }

  Future<bool> requestAuthorization() async {
    try {
      return await _platform.requestAuthorization();
    } on PlatformException catch (e) {
      return false;
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
}
