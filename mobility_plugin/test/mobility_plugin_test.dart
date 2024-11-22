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

  @override
  Future<List<dynamic>> getMobilityData() => Future.value([
        {
          'value': 1.5,
          'startDate': 1633036800,
          'endDate': 1633036860,
        },
        // Add more mock data if needed
      ]);

  @override
  Future<void> requestAuthorization() => Future.value();
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

  test('getMobilityData', () async {
    MobilityPlugin mobilityPlugin = MobilityPlugin();
    MockMobilityPluginPlatform fakePlatform = MockMobilityPluginPlatform();
    MobilityPluginPlatform.instance = fakePlatform;

    final data = await mobilityPlugin.getMobilityData();
    expect(data, isNotEmpty);
    expect(data.first['value'], 1.5);
  });
}
