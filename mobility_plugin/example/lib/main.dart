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
  List<Map<String, dynamic>> _mobilityData = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _mobilityPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException catch (e) {
      platformVersion = 'Failed to get platform version: ${e.message}';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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

  Future<void> fetchMobilityData() async {
    try {
      List<dynamic> data = await _mobilityPlugin.getMobilityData();
      if (!mounted) return;

      setState(() {
        _mobilityData = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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

  double _convertToMph(double metersPerSecond) {
    return metersPerSecond * 2.23694;
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
                      ? ListView.builder(
                          itemCount: _mobilityData.length,
                          itemBuilder: (context, index) {
                            final data = _mobilityData[index];
                            double speedMph = _convertToMph(data['value']);
                            return ListTile(
                              title: Text('Speed: ${speedMph.toStringAsFixed(2)} mph'),
                              subtitle: Text(
                                'Start: ${DateTime.fromMillisecondsSinceEpoch((data['startDate'] * 1000).toInt())}\n'
                                'End: ${DateTime.fromMillisecondsSinceEpoch((data['endDate'] * 1000).toInt())}',
                              ),
                            );
                          },
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