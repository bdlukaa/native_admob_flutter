import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../events.dart';
import '../mobile_ads.dart';
import '../utils.dart';

/// Portrait orientation
const int APP_OPEN_AD_ORIENTATION_PORTRAIT = 1;

/// Landscape orientation
const int APP_OPEN_AD_ORIENTATION_LANDSCAPE = 2;

// /// The events a [AppOpenAd] can receive. Listen
// /// to the events using `appOpenAd.onEvent.listen((event) {})`.
// ///
// /// Avaiable events:
// ///   - loading (When the ad starts loading)
// ///   - loaded (When the ad is loaded)
// ///   - loadFailed (When the ad failed to load)
// ///   - showed (When the ad showed successfully)
// ///   - showFailed (When it failed on showing)
// ///   - dimissed (When the ad is closed)
// ///
// /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#ad-events)
// enum AppOpenEvent {
//   /// Called when the ad starts loading. This event is usually thrown by `ad.load()`
//   ///
//   /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#load-the-ad)
//   loading,

//   /// Called when the ad is loaded. This event is usually thrown by `ad.load()`
//   ///
//   /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#load-the-ad)
//   loaded,

//   /// Called when the load failed. This event is usually thrown by `ad.load()`
//   ///
//   /// Attempting to load a new ad from the `loadFailed` event is strongly discouraged.
//   /// If you must load an ad from this event, limit ad load retries to avoid
//   /// continuous failed ad requests in situations such as limited network connectivity.
//   ///
//   /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#load-the-ad)
//   loadFailed,

//   /// Called when the ad is closed. The same as `await ad.show()`
//   ///
//   /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#show-the-ad)
//   dismissed,

//   /// Called when it failed on showing. This event is usually thrown by `ad.show()`
//   ///
//   /// Attempting to show the ad again from the `showFailed` event is strongly discouraged.
//   /// If you must show the ad from this event, limit ad show retries to avoid
//   /// continuous failed attempts in situations such as limited network connectivity.
//   ///
//   /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#show-the-ad)
//   showFailed,

//   /// Called when it showed successfully. This event is usually thrown by `ad.show()`
//   ///
//   /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#show-the-ad)
//   showed,
// }

/// An AppOpenAd model to communicate with the model in the platform side.
/// It gives you methods to help in the implementation and event tracking.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/app-open-ads
///   - https://developers.google.com/admob/ios/app-open-ads
class AppOpenAd extends LoadShowAd<FullScreenAdEvent> {
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
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#ad-events)
  Stream<Map<FullScreenAdEvent, dynamic>> get onEvent => super.onEvent;

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

  /// Check if the ad is currently on the screen or not.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#show-the-ad)
  bool get isShowing => _isShowing;

  /// The duration a ad can be kept loaded. Default to 1 hour.
  /// This can NOT be null. If so, an `AssertionError` is thrown
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#consider-ad-expiration)
  Duration timeout;

  /// Creates a new AppOpenAd instance.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#creating-an-ad-object)
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
        onEventController.add({FullScreenAdEvent.loading: null});
        break;
      case 'onAppOpenAdFailedToLoad':
        onEventController.add({
          FullScreenAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAppOpenAdLoaded':
        _isAvaiable = true;
        onEventController.add({FullScreenAdEvent.loaded: null});
        break;
      case 'onAdDismissedFullScreenContent':
        _isAvaiable = false;
        _isShowing = false;
        onEventController.add({FullScreenAdEvent.closed: null});
        break;
      case 'onAdFailedToShowFullScreenContent':
        onEventController.add({
          FullScreenAdEvent.showFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdShowedFullScreenContent':
        _isShowing = true;
        onEventController.add({FullScreenAdEvent.showed: null});
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
    /// The ad unit id. If null, [MobileAds.appOpenAdUnitId] is used
    String unitId,

    /// The orientation. Avaiable orientations:\
    /// 1 - [APP_OPEN_AD_ORIENTATION_PORTRAIT]\
    /// 2 - [APP_OPEN_AD_ORIENTATION_LANDSCAPE]\
    ///
    /// If null, defaults to the current device orientation
    int orientation,

    /// Force to load an ad even if another is already avaiable
    bool force = false,
  }) async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    if (!debugCheckAdWillReload(isAvaiable, force)) return false;
    if (orientation != null)
      assert(
        [APP_OPEN_AD_ORIENTATION_PORTRAIT, APP_OPEN_AD_ORIENTATION_LANDSCAPE]
            .contains(orientation),
        'The orientation must be a valid orientation: $APP_OPEN_AD_ORIENTATION_PORTRAIT, $APP_OPEN_AD_ORIENTATION_LANDSCAPE',
      );
    else {
      final window = WidgetsBinding.instance.window;
      final size = window.physicalSize / window.devicePixelRatio;
      final deviceOrientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;

      switch (deviceOrientation) {
        case Orientation.landscape:
          orientation = APP_OPEN_AD_ORIENTATION_LANDSCAPE;
          break;
        case Orientation.portrait:
          orientation = APP_OPEN_AD_ORIENTATION_PORTRAIT;
          break;
      }
    }
    print(orientation);
    final loaded = await channel.invokeMethod<bool>('loadAd', {
      'unitId':
          unitId ?? MobileAds.appOpenAdUnitId ?? MobileAds.appOpenAdTestUnitId,
      'orientation': orientation,
    });
    if (loaded) _lastLoadedTime = DateTime.now();
    return loaded;
  }

  /// Show the ad. It must be loaded in order to be showed.
  /// You can use the `load()` method to load it
  ///
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
    assertMobileAdsIsInitialized();
    assert(
      isAvaiable,
      'Can NOT show an ad that is not loaded. '
      'Call await appOpenAd.load() before showing it',
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
