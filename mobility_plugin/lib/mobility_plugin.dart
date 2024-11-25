import 'mobility_plugin_platform_interface.dart';

class MobilityPlugin {
  Future<String?> getPlatformVersion() {
    return MobilityPluginPlatform.instance.getPlatformVersion();
  }

  Future<Map<String, dynamic>> getAllMobilityData() {
    return MobilityPluginPlatform.instance.getAllMobilityData();
  }

  Future<Map<String, dynamic>> getMobilityData({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return MobilityPluginPlatform.instance.getMobilityData(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> getRecentMobilityData({
    required int limit,
  }) {
    return MobilityPluginPlatform.instance.getRecentMobilityData(
      limit: limit,
    );
  }

  Future<void> requestAuthorization() {
    return MobilityPluginPlatform.instance.requestAuthorization();
  }
}