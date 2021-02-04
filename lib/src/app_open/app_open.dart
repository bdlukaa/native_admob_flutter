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
/// It gives you methods to help in the implementation and event tracking.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/app-open-ads
///   - https://developers.google.com/admob/ios/app-open-ads
class AppOpenAd extends LoadShowAd<AppOpenEvent> {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/3419835294
  ///   - iOS: ca-app-pub-3940256099942544/5662855259
  static String get testUnitId => MobileAds.appOpenAdTestUnitId;

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
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#load-the-ad)
  Stream<Map<AppOpenEvent, dynamic>> get onEvent => super.onEvent;

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

  /// The duration a ad can be kept loaded. Default to 1 hour
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#consider-ad-expiration)
  Duration timeout;

  /// Creates a new AppOpenAd instance. Don't forget to dipose
  /// it when you finish using it to free up resources
  AppOpenAd([this.timeout = const Duration(hours: 1)])
      : assert(timeout != null, 'The timeout time can NOT be null'),
        super();

  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initAppOpenAd', {'id': id});
  }

  Future<void> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    switch (call.method) {
      case 'loading':
        onEventController.add({AppOpenEvent.loading: null});
        break;
      case 'onAppOpenAdFailedToLoad':
        onEventController.add({
          AppOpenEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAppOpenAdLoaded':
        _isAvaiable = true;
        onEventController.add({AppOpenEvent.loaded: null});
        break;
      case 'onAdDismissedFullScreenContent':
        _isAvaiable = false;
        _isShowing = false;
        onEventController.add({AppOpenEvent.dismissed: null});
        break;
      case 'onAdFailedToShowFullScreenContent':
        onEventController.add({
          AppOpenEvent.showFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdShowedFullScreenContent':
        _isShowing = true;
        onEventController.add({AppOpenEvent.showed: null});
        break;
    }
  }

  /// Load the ad. Shows a warning if the ad is already loaded
  ///
  /// Returns `true` if the ad was loaded successfully or `false`
  /// if an error happened
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#load-the-ad)
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
    ensureAdNotDisposed();
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
    bool loaded = await channel.invokeMethod<bool>('loadAd', {
      'unitId':
          unitId ?? MobileAds.appOpenAdUnitId ?? MobileAds.appOpenAdTestUnitId,
      'orientation': orientation ?? APP_OPEN_AD_ORIENTATION_PORTRAIT,
    });
    if (loaded) _lastLoadedTime = DateTime.now();
    return loaded;
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
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#show-the-ad)
  Future<bool> show() {
    ensureAdNotDisposed();
    assert(
      isAvaiable,
      'Can NOT show an ad that is not loaded. Call await appOpenAd.load() before showing it',
    );
    return channel.invokeMethod<bool>('showAd');
  }

  /// Dispose the ad to free up resouces.
  /// Once disposed, the ad can not be used anymore.
  ///
  /// If you try to use a disposed ad, an `AssertionError will be thrown`
  void dispose() {
    super.dispose();
    MobileAds.pluginChannel.invokeMethod('disposeAppOpenAd', {'id': id});
  }
}
