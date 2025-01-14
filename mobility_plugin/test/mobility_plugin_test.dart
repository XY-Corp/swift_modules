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
  Future<Map<String, dynamic>> getMobilityData({
    required DateTime startDate,
    required DateTime endDate,
  }) => Future.value({
        'walkingSpeed': [
          {
            'value': 1.5,
            'startDate': startDate.millisecondsSinceEpoch ~/ 1000,
            'endDate': endDate.millisecondsSinceEpoch ~/ 1000,
          },
          // Add more mock data if needed
        ],
        // Add other mobility data if needed
      });

  @override
  Future<void> requestAuthorization() => Future.value();

  @override
  Future<Map<String, dynamic>> getAllMobilityData() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getMobilityDataByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return Future.value({
      'data': [
        {
          'value': 1.8,
          'startDate': startDate.millisecondsSinceEpoch,
          'endDate': endDate.millisecondsSinceEpoch,
        },
      ],
    });
  }

  @override
  Future<Map<String, dynamic>> getRecentMobilityData({
    required int limit,
  }) {
    return Future.value({
      'walkingSpeed': List.generate(limit, (index) => {
        'value': 1.5 + index * 0.1,
        'startDate': DateTime.now().millisecondsSinceEpoch - index * 60000,
        'endDate': DateTime.now().millisecondsSinceEpoch - index * 60000 + 5000,
      }),
    });
  }
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

    final data = await mobilityPlugin.getMobilityData(
      startDate: DateTime(2021, 10, 1),
      endDate: DateTime(2021, 10, 2),
    );
    expect(data, isNotEmpty);
    expect(data['walkingSpeed'], isNotNull);
    expect(data['walkingSpeed'], isA<List<dynamic>>());
    expect(data['walkingSpeed'][0]['value'], 1.5);
  });

  test('getRecentMobilityData', () async {
    MobilityPlugin mobilityPlugin = MobilityPlugin();
    MockMobilityPluginPlatform fakePlatform = MockMobilityPluginPlatform();
    MobilityPluginPlatform.instance = fakePlatform;

    final data = await mobilityPlugin.getRecentMobilityData(limit: 5);
    expect(data, isNotEmpty);
    expect(data['walkingSpeed'], isNotNull);
    expect(data['walkingSpeed'], isA<List<dynamic>>());
    expect(data['walkingSpeed'].length, 5);
    expect(data['walkingSpeed'][0]['value'], 1.5);
  });

  test('getMobilityDataByType', () async {
    MobilityPlugin mobilityPlugin = MobilityPlugin();
    MockMobilityPluginPlatform fakePlatform = MockMobilityPluginPlatform();
    MobilityPluginPlatform.instance = fakePlatform;

    final data = await mobilityPlugin.getMobilityDataByType(
      type: 'WALKING_SPEED',
      startDate: DateTime(2021, 10, 1),
      endDate: DateTime(2021, 10, 2),
    );
    expect(data, isNotEmpty);
    expect(data['data'], isNotNull);
    expect(data['data'], isA<List<dynamic>>());
    expect(data['data'][0]['value'], 1.8);
  });
}
