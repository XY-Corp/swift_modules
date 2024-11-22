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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<List<dynamic>> getMobilityData() {
    throw UnimplementedError('getMobilityData() has not been implemented.');
  }

  Future<void> requestAuthorization() {
    throw UnimplementedError('requestAuthorization() has not been implemented.');
  }
}
