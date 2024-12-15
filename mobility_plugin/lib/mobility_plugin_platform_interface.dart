import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'mobility_plugin_method_channel.dart';

abstract class MobilityPluginPlatform extends PlatformInterface {
  /// Constructs a MobilityPluginPlatform.
  MobilityPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MobilityPluginPlatform _instance = MethodChannelMobilityPlugin();

  /// The default instance of [MobilityPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMobilityPlugin].
  static MobilityPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MobilityPluginPlatform] when
  /// they register themselves.
  static set instance(MobilityPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<Map<String, dynamic>> getAllMobilityData();

  Future<Map<String, dynamic>> getMobilityData({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Map<String, dynamic>> getRecentMobilityData({
    required int limit,
  });

  Future<void> requestAuthorization();

  Future<Map<String, dynamic>> getMobilityDataByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetches mindfulness data within a date range.
  Future<List<Map<String, dynamic>>> getMindfulnessData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetches recent mindfulness data with a limit.
  Future<List<Map<String, dynamic>>> getRecentMindfulnessData({
    required int limit,
  });
}