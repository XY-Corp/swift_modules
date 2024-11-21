import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_plugin/mobility_plugin.dart';
import 'package:mobility_plugin/mobility_plugin_platform_interface.dart';
import 'package:mobility_plugin/mobility_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMobilityPluginPlatform
    with MockPlatformInterfaceMixin
    implements MobilityPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MobilityPluginPlatform initialPlatform = MobilityPluginPlatform.instance;

  test('$MethodChannelMobilityPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMobilityPlugin>());
  });

  test('getPlatformVersion', () async {
    MobilityPlugin mobilityPlugin = MobilityPlugin();
    MockMobilityPluginPlatform fakePlatform = MockMobilityPluginPlatform();
    MobilityPluginPlatform.instance = fakePlatform;

    expect(await mobilityPlugin.getPlatformVersion(), '42');
  });
}
