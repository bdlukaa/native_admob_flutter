import 'dart:async';

import 'package:flutter/services.dart';

import '../mobile_ads.dart';
import '../utils.dart';

/// Landscape orientation
const int APP_OPEN_AD_ORIENTATION_PORTRAIT = 1;

/// Portrait orientation
const int APP_OPEN_AD_ORIENTATION_LANDSCAPE = 2;

enum AppOpenEvent {
  loading,
  loaded,
  loadFailed,
  dismissed,
  showFailed,
  showed,
}

class AppOpenAd with UniqueKeyMixin {
  static String get testUnitId => MobileAds.appOpenAdTestUnitId;

  final _onEvent = StreamController<Map<AppOpenEvent, dynamic>>.broadcast();
  Stream<Map<AppOpenEvent, dynamic>> get onEvent => _onEvent.stream;

  bool _disposed = false;

  bool _isAvaiable = false;

  DateTime _lastLoadedTime;

  /// Check if the ad is avaiable. Default to `false`
  ///
  /// This turns `true` when the ad is loaded
  ///
  /// If the timeout time
  bool get isAvaiable {
    if (_lastLoadedTime != null && timeout != null) {
      final difference = _lastLoadedTime.difference(DateTime.now());
      if (difference > timeout) return false;
    }
    return _isAvaiable;
  }

  bool _isShowing = false;

  /// Check if the ad is currently showing.
  bool get isShowing => _isShowing;

  /// Channel to communicate with controller
  MethodChannel _channel;

  /// The duration a ad can be kept loaded. Default to 1 hour
  Duration timeout;

  AppOpenAd([this.timeout = const Duration(hours: 1)]) {
    assert(timeout != null, 'The timeout can NOT be null');
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);

    MobileAds.pluginChannel.invokeMethod('initAppOpenAd', {'id': id});
  }

  Future<void> _handleMessages(MethodCall call) async {
    if (_disposed) return;
    switch (call.method) {
      case 'loading':
        _onEvent.add({AppOpenEvent.loading: null});
        break;
      case 'onAppOpenAdFailedToLoad':
        _onEvent.add({
          AppOpenEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAppOpenAdLoaded':
        _isAvaiable = true;
        _onEvent.add({AppOpenEvent.loaded: null});
        break;
      case 'onAdDismissedFullScreenContent':
        _isAvaiable = false;
        _isShowing = false;
        _onEvent.add({AppOpenEvent.dismissed: null});
        break;
      case 'onAdFailedToShowFullScreenContent':
        _onEvent.add({
          AppOpenEvent.showFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdShowedFullScreenContent':
        _isShowing = true;
        _onEvent.add({AppOpenEvent.showed: null});
        break;
    }
  }

  /// Load the ad. Shows a warning if the ad is already loaded
  ///
  /// Returns `true` if the ad was loaded successfully or `false`
  /// if an error happened
  Future<bool> load({
    /// The ad unit id
    String unitId,

    /// The orientation. Avaiable orientations:\
    /// 1 - APP_OPEN_AD_ORIENTATION_PORTRAIT\
    /// 2 - APP_OPEN_AD_ORIENTATION_LANDSCAPE\
    ///
    /// Failure to use them will result in an `AssertionError`
    int orientation = APP_OPEN_AD_ORIENTATION_PORTRAIT,
  }) async {
    _ensureAdNotDisposed();
    if (isAvaiable) {
      print('An ad is already avaiable, no need to load another');
      return false;
    }
    if (orientation != null)
      assert(
        [APP_OPEN_AD_ORIENTATION_PORTRAIT, APP_OPEN_AD_ORIENTATION_LANDSCAPE]
            .contains(orientation),
        'The orientation must be a valid orientation: $APP_OPEN_AD_ORIENTATION_PORTRAIT, $APP_OPEN_AD_ORIENTATION_LANDSCAPE',
      );
    try {
      await _channel.invokeMethod('loadAd', {
        'unitId': unitId ??
            MobileAds.appOpenAdUnitId ??
            MobileAds.appOpenAdTestUnitId,
        'orientation': orientation ?? APP_OPEN_AD_ORIENTATION_PORTRAIT,
      });
      _lastLoadedTime = DateTime.now();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Make sure to check if the ad is avaiable using the getter `isAvaiable`
  ///
  /// ```dart
  /// void showIfAvaiable() {
  ///   if (isAvaiable) appOpenAd.show();
  ///   else {
  ///     await appOpenAd.load();
  ///     showIfAvaiable();
  ///   }
  /// }
  /// ```
  Future<void> show() {
    _ensureAdNotDisposed();
    assert(
      isAvaiable,
      'Can NOT show an ad that is not loaded. Call await appOpenAd.load() before showing it',
    );
    return _channel.invokeMethod('showAd');
  }

  /// Dispose the ad to free up resouces.
  /// Once disposed, the ad can not be used anymore.
  void dispose() {
    _ensureAdNotDisposed();
    _disposed = true;
    _onEvent.close();
    MobileAds.pluginChannel.invokeMethod('disposeAppOpenAd', {'id': id});
  }

  void _ensureAdNotDisposed() {
    assert(!_disposed, 'You can NOT use a disposed ad');
  }
}
