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

  Future<bool> requestAuthorization() {
    return _platform.requestAuthorization();
  }

  Future<bool> hasMobilityPermissions() {
    return _platform.hasMobilityPermissions();
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