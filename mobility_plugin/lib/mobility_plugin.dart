import 'mobility_plugin_platform_interface.dart';

class MobilityPlugin {
  static final MobilityPluginPlatform _platform = MobilityPluginPlatform.instance;

  Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  Future<Map<String, dynamic>> getAllMobilityData() {
    return _platform.getAllMobilityData();
  }

  Future<Map<String, dynamic>> getMobilityData({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _platform.getMobilityData(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> getRecentMobilityData({
    required int limit,
  }) {
    return _platform.getRecentMobilityData(limit: limit);
  }

  Future<void> requestAuthorization() {
    return _platform.requestAuthorization();
  }

  Future<Map<String, dynamic>> getMobilityDataByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _platform.getMobilityDataByType(
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
}