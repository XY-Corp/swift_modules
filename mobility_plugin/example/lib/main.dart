import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mobility_plugin/mobility_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MobilityPlugin _mobilityPlugin = MobilityPlugin();
  String _platformVersion = 'Unknown';
  Map<String, List<Map<String, dynamic>>> _mobilityData = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _mobilityPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException catch (e) {
      platformVersion = 'Failed to get platform version: ${e.message}';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> fetchMobilityData() async {
    DateTime endDate = DateTime.now();
    DateTime startDate =
        DateTime.now().subtract(const Duration(days: 7)); // Last 7 days

    try {
      Map<String, dynamic> rawData = await _mobilityPlugin.getMobilityData(
        startDate: startDate,
        endDate: endDate,
      );
      if (!mounted) return;

      setState(() {
        _mobilityData = rawData.map((key, value) {
          return MapEntry(
            key,
            (value as List)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList(),
          );
        });
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mobilityData.clear();
        _errorMessage = 'Failed to fetch mobility data: $e';
      });
    }
  }

  Future<void> requestAuthorization() async {
    try {
      await _mobilityPlugin.requestAuthorization();
      if (!mounted) return;

      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to request authorization: $e';
      });
    }
  }

  double _convertToMph(double metersPerSecond) {
    return metersPerSecond * 2.23694;
  }

  String _dataPointToString(String key, Map<String, dynamic> dataPoint) {
    double value = dataPoint['value'];
    String unit = '';
    switch (key) {
      case 'walkingSpeed':
        value = _convertToMph(value);
        unit = 'mph';
        break;
      case 'stepLength':
        unit = 'm';
        break;
      case 'doubleSupportPercentage':
      case 'asymmetryPercentage':
        unit = '%';
        break;
      case 'walkingSteadiness':
        unit = '';
        break;
      default:
        unit = '';
    }
    return '${value.toStringAsFixed(2)} $unit';
  }

  String _getDisplayName(String key) {
    switch (key) {
      case 'walkingSpeed':
        return 'Walking Speed';
      case 'doubleSupportPercentage':
        return 'Double Support Percentage';
      case 'stepLength':
        return 'Step Length';
      case 'asymmetryPercentage':
        return 'Walking Asymmetry';
      case 'walkingSteadiness':
        return 'Walking Steadiness';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobility Plugin Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mobility Plugin Example App'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Running on: $_platformVersion\n'),
                ElevatedButton(
                  onPressed: requestAuthorization,
                  child: const Text('Request Permissions'),
                ),
                ElevatedButton(
                  onPressed: fetchMobilityData,
                  child: const Text('Fetch Mobility Data'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _mobilityData.isNotEmpty
                      ? ListView(
                          children: _mobilityData.entries.map((entry) {
                            String key = entry.key;
                            List<Map<String, dynamic>> dataPoints = entry.value;
                            return ExpansionTile(
                              title: Text(_getDisplayName(key)),
                              children: dataPoints.map((dataPoint) {
                                return ListTile(
                                  title:
                                      Text(_dataPointToString(key, dataPoint)),
                                  subtitle: Text(
                                    'Start: ${DateTime.fromMillisecondsSinceEpoch((dataPoint['startDate'] * 1000).toInt())}\n'
                                    'End: ${DateTime.fromMillisecondsSinceEpoch((dataPoint['endDate'] * 1000).toInt())}',
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        )
                      : _errorMessage != null
                          ? Text(_errorMessage!)
                          : const Text('No mobility data available.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
