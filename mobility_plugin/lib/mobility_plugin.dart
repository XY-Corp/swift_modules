
import 'mobility_plugin_platform_interface.dart';

class MobilityPlugin {
  Future<String?> getPlatformVersion() {
    return MobilityPluginPlatform.instance.getPlatformVersion();
  }

  Future<Map<String, dynamic>> getMobilityData() {
    return MobilityPluginPlatform.instance.getMobilityData();
  }

  Future<void> requestAuthorization() {
    return MobilityPluginPlatform.instance.requestAuthorization();
  }
}
