
import 'mobility_plugin_platform_interface.dart';

class MobilityPlugin {
  Future<String?> getPlatformVersion() {
    return MobilityPluginPlatform.instance.getPlatformVersion();
  }

  Future<List<dynamic>> getMobilityData() {
    return MobilityPluginPlatform.instance.getMobilityData();
  }
}
