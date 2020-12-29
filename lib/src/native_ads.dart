import 'package:flutter/services.dart';

class NativeAds {
  static String nativeAdUnitId;
  static String testAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  static final _pluginChannel = const MethodChannel("native_admob_flutter");

  static Future<void> initialize([String nativeAdUnitId]) async {
    NativeAds.nativeAdUnitId = nativeAdUnitId ?? NativeAds.testAdUnitId;
    assert(NativeAds.nativeAdUnitId != null);
    await _pluginChannel.invokeMethod('initialize', {
      'admob_app_id': NativeAds.nativeAdUnitId,
    });
  }

  static Future<void> setTestDeviceIds(List<String> ids) async {
    if (ids == null || ids.isEmpty) return;

    await _pluginChannel.invokeMethod("setTestDeviceIds", {"ids": ids});
  }
}
