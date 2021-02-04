import 'dart:async';

import 'package:flutter/services.dart';

import '../mobile_ads.dart';
import '../utils.dart';

/// Portrait orientation
const int APP_OPEN_AD_ORIENTATION_PORTRAIT = 1;

/// Landscape orientation
const int APP_OPEN_AD_ORIENTATION_LANDSCAPE = 2;

enum AppOpenEvent {
  /// Called when the ad starts loading
  loading,

  /// Called when the ad is loaded
  loaded,

  /// Called when the load failed
  ///
  /// Attempting to load a new ad from the `loadFailed` event is strongly discouraged.
  /// If you must load an ad from onAppOpenAdFailedToLoad(), limit ad load retries to
  /// avoid continuous failed ad requests in situations such as limited network connectivity.
  loadFailed,

  /// Called when the ad is closed
  dismissed,

  /// Called when it failed on showing
  showFailed,

  /// Called when it showed successfully
  showed,
}

/// An AppOpenAd model to communicate with the model in the platform side.
/// For more info, see:
///   - https://developers.google.com/admob/android/app-open-ads
///   - https://developers.google.com/admob/ios/app-open-ads
class AppOpenAd with UniqueKeyMixin {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/3419835294
  ///   - iOS: ca-app-pub-3940256099942544/5662855259
  static String get testUnitId => MobileAds.appOpenAdTestUnitId;

  final _onEvent = StreamController<Map<AppOpenEvent, dynamic>>.broadcast();

  /// Listen to the events the ad throws
  ///
  /// Usage:
  /// ```dart
  /// appOpenAd.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   // final info = e.values.first;
  ///   switch (event) {
  ///     case AppOpenEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case AppOpenEvent.loadFailed:
  ///       print('load failed');
  ///       break;
  ///     case AppOpenEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case AppOpenEvent.showed:
  ///       print('ad showed');
  ///       break;
  ///     case AppOpenEvent.showFailed:
  ///       print('show failed');
  ///       break;
  ///     case AppOpenEvent.dismissed:
  ///       // You may want to dismiss your loading screen here
  ///       print('ad dismissed');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<Map<AppOpenEvent, dynamic>> get onEvent => _onEvent.stream;

  bool _disposed = false;

  bool _isAvaiable = false;

  DateTime _lastLoadedTime;

  /// Check if the ad is avaiable. Default to `false`
  ///
  /// This turns `true` when the ad is loaded
  ///
  /// If the timeout time is over since the last time it was loaded
  /// thne it'll return `false`
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

  /// Creates a new AppOpenAd instance. Don't forget to dipose
  /// it when you finish using it to free up resources
  AppOpenAd([this.timeout = const Duration(hours: 1)]) {
    assert(timeout != null, 'The timeout time can NOT be null');
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
  ///
  /// If you try to use a disposed ad, an `AssertionError will be thrown`
  void dispose() {
    _ensureAdNotDisposed();
    _disposed = true;
    _onEvent.close();
    MobileAds.pluginChannel.invokeMethod('disposeAppOpenAd', {'id': id});
  }

  /// Make sure the ad is not disposed when using it
  void _ensureAdNotDisposed() {
    assert(!_disposed, 'You can NOT use a disposed ad');
  }
}
