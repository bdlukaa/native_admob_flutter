import 'dart:async';

import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';
import '../utils.dart';

enum InterstitialAdEvent {
  /// Called when a click is recorded for an ad.
  clicked,

  /// Called when an ad request failed.
  ///
  /// **Warning**: Attempting to load a new ad when the load fail
  /// is strongly discouraged. If you must load an ad when it fails,
  /// limit ad load retries to avoid continuous failed ad requests in
  /// situations such as limited network connectivity.
  loadFailed,

  /// Called when an ad is received.
  loaded,

  /// Called when the ad starts loading
  loading,

  /// Called when the event is unkown (usually for rebuilding ui)
  undefined,

  /// Called when the interstitial ad is opened
  opened,

  /// Called when the interstitial ad is closed
  closed,

  /// Called when the user has left the app
  leftApplication,
}

/// An InterstitialAd model to communicate with the model in the platform side.
/// It gives you methods to help in the implementation and event tracking.
/// 
/// For more info, see:
///   - https://developers.google.com/admob/android/interstitial-fullscreen
///   - https://developers.google.com/admob/ios/interstitial
class InterstitialAd extends LoadShowAd<InterstitialAdEvent> {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/1033173712
  ///   - iOS: ca-app-pub-3940256099942544/4411468910
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get testUnitId => MobileAds.interstitialAdTestUnitId;

  /// The video test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/8691691433
  ///   - iOS: ca-app-pub-3940256099942544/5135589807
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get videoTestUnitId => MobileAds.interstitialAdVideoTestUnitId;

  /// Listen to the events the ad throws
  ///
  /// Usage:
  /// ```dart
  /// ad.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case InterstitialAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case InterstitialAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case InterstitialAdEvent.loadFailed:
  ///       final errorCode = e.values.first;
  ///       print('loadFailed $errorCode');
  ///       break;
  ///     case InterstitialAdEvent.opened:
  ///       print('ad opened');
  ///       break;
  ///     case InterstitialAdEvent.closed:
  ///       print('ad closed');
  ///       break;
  ///     case InterstitialAdEvent.clicked;
  ///       print('clicked');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#ad-events)
  Stream<Map<InterstitialAdEvent, dynamic>> get onEvent => super.onEvent;

  bool _loaded = false;

  /// Returns true if the ad was successfully loaded and is ready to be shown.
  bool get isLoaded => _loaded;

  String unitId;

  /// Creates a new native ad controller
  ///
  /// If `unitId` is null, `MobileAds.interstitialAdUnitId` or
  /// `MobileAds.interstitialAdTestUnitId` is used
  InterstitialAd([this.unitId]) : super();

  /// Initialize the controller. This can be called only by the controller
  void init() {
    channel.setMethodCallHandler(_handleMessages);
    unitId ??=
        MobileAds.interstitialAdUnitId ?? MobileAds.interstitialAdTestUnitId;
    MobileAds.pluginChannel.invokeMethod('initInterstitialAd', {
      'id': id,
      'unitId': unitId,
    });
  }

  /// Dispose the ad to free up resources.
  /// Once disposed, the ad can not be used anymore
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   super.dispose();
  ///   interstitialAd?.dispose();
  /// }
  /// ```
  void dispose() {
    super.dispose();
    MobileAds.pluginChannel.invokeMethod('disposeInterstitialAd', {'id': id});
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    switch (call.method) {
      case 'loading':
        onEventController.add({InterstitialAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        onEventController.add(
            {InterstitialAdEvent.loadFailed: AdError.fromJson(call.arguments)});
        break;
      case 'onAdLoaded':
        onEventController.add({InterstitialAdEvent.loaded: null});
        break;
      case 'onAdClicked':
        onEventController.add({InterstitialAdEvent.clicked: null});
        break;
      case 'onAdOpened':
        onEventController.add({InterstitialAdEvent.opened: null});
        break;
      case 'onAdClosed':
        onEventController.add({InterstitialAdEvent.closed: null});
        break;
      case 'onAdLeftApplication':
        onEventController.add({InterstitialAdEvent.leftApplication: null});
        break;
      case 'undefined':
      default:
        onEventController.add({InterstitialAdEvent.undefined: null});
        break;
    }
  }

  /// In order to show an ad, it needs to be loaded first. Use `load()` to load.
  ///
  /// To check if the ad is loaded, call `interstitialAd.isLoaded`. You can't `show()`
  /// an ad if it's not loaded.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#load-the-ad)
  Future<bool> load() async {
    assertMobileAdsIsInitialized();
    _loaded = await channel.invokeMethod<bool>('loadAd', null);
    return _loaded;
  }

  /// Show the interstitial ad. This returns a `Future` that will complete when
  /// the ad gets closed
  ///
  /// The ad must be loaded. To check if the ad is loaded, call
  /// `interstitialAd.isLoaded`. If it's not loaded, throws an `AssertionError`
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#show-the-ad)
  Future<bool> show() {
    assert(isLoaded, '''The ad must be loaded to show. 
      Call interstitialAd.load() to load the ad. 
      Call interstitialAd.isLoaded to check if the ad is loaded before showing.''');
    return channel.invokeMethod<bool>('show');
  }
}
