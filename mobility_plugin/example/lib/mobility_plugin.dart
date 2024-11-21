import 'dart:async';
import 'package:flutter/services.dart';

class MobilityPlugin {
  static const MethodChannel _channel = MethodChannel('mobility_plugin');

  Future<String?> getPlatformVersion() async {
    try {
      final String? version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      throw 'Failed to get platform version: ${e.message}';
    }
  }

  Future<List<dynamic>> getMobilityData() async {
    try {
      final List<dynamic> data = await _channel.invokeMethod('getMobilityData');
      return data;
    } on PlatformException catch (e) {
      throw 'Failed to get mobility data: ${e.message}';
    }
  }
}