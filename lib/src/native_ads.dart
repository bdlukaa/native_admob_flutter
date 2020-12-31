import 'package:flutter/services.dart';

class NativeAds {
  static String nativeAdUnitId;
  static String testAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  static final _pluginChannel = const MethodChannel("native_admob_flutter");

  static bool _initialized = false;

  /// Check if the ADMOB is initialized. To initialize it, use
  /// `NativeAds.initialize()`
  static bool get isInitialized => _initialized;

  /// Before creating any native ads, you must initalize the admob. It can be initialized only once:
  ///
  /// ```dart
  /// void main() async {
  ///   // Add this line if you will initialize it before runApp
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   // default admob app id: ca-app-pub-3940256099942544/2247696110
  ///   /* await */ NativeAds.initialize('your-admob-app-id');
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize([String nativeAdUnitId]) async {
    NativeAds.nativeAdUnitId = nativeAdUnitId ?? NativeAds.testAdUnitId;
    assert(NativeAds.nativeAdUnitId != null);
    await _pluginChannel.invokeMethod('initialize', {
      'admob_app_id': NativeAds.nativeAdUnitId,
    });
    _initialized = true;
  }

  static Future<void> setTestDeviceIds(List<String> ids) async {
    if (ids == null || ids.isEmpty) return;

    await _pluginChannel.invokeMethod("setTestDeviceIds", {"ids": ids});
  }
}
