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
  List<dynamic> _mobilityData = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    fetchMobilityData();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
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

  Future<void> fetchMobilityData() async {
    try {
      List<dynamic> data = await _mobilityPlugin.getMobilityData();
      if (!mounted) return;

      setState(() {
        _mobilityData = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mobilityData = ['Failed to fetch mobility data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mobility Plugin Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('Mobility Data: ${_mobilityData.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}