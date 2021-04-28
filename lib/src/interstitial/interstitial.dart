import 'dart:async';

import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';
import '../events.dart';
import '../utils.dart';

/// An InterstitialAd model to communicate with the model in the platform side.
/// It gives you methods to help in the implementation and event tracking.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/interstitial-fullscreen
///   - https://developers.google.com/admob/ios/interstitial
class InterstitialAd extends LoadShowAd<FullScreenAdEvent> {
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
  ///     case FullScreenAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case FullScreenAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case FullScreenAdEvent.loadFailed:
  ///       final error = e.values.first;
  ///       print('loadFailed ${error.code}');
  ///       break;
  ///     case FullScreenAdEvent.showed:
  ///       print('ad showed');
  ///       break;
  ///     case FullScreenAdEvent.failedToShow;
  ///       final error = e.values.first;
  ///       print('ad failed to show ${error.code}');
  ///       break;
  ///     case FullScreenAdEvent.closed:
  ///       print('ad closed');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#ad-events)
  Stream<Map<FullScreenAdEvent, dynamic>> get onEvent => super.onEvent;

  /// Creates a new interstitial ad controller
  InterstitialAd({
    String? unitId,
    Duration loadTimeout = kDefaultLoadTimeout,
    Duration timeout = kDefaultAdTimeout,
    bool nonPersonalizedAds = kDefaultNonPersonalizedAds,
  }) : super(
          unitId: unitId,
          loadTimeout: loadTimeout,
          timeout: timeout,
          nonPersonalizedAds: nonPersonalizedAds,
        );

  /// Initialize the controller. This can be called only by the controller
  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initInterstitialAd', {'id': id});
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
        onEventController.add({FullScreenAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        isLoaded = false;
        onEventController.add({
          FullScreenAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdLoaded':
        isLoaded = true;
        onEventController.add({FullScreenAdEvent.loaded: null});
        break;
      case 'onAdShowedFullScreenContent':
        isLoaded = false;
        onEventController.add({FullScreenAdEvent.showed: null});
        break;
      case 'onAdFailedToShowFullScreenContent':
        onEventController.add({
          FullScreenAdEvent.showFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdDismissedFullScreenContent':
        onEventController.add({FullScreenAdEvent.closed: null});
        break;
      default:
        break;
    }
  }

  /// In order to show an ad, it needs to be loaded first. Use `load()` to load.
  ///
  /// To check if the ad is loaded, call `interstitialAd.isLoaded`. You can't `show()`
  /// an ad if it's not loaded.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#load-the-ad)
  ///
  /// If `unitId` is null, `MobileAds.interstitialAdUnitId` or
  /// `MobileAds.interstitialAdTestUnitId` is used
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#load-the-ad)
  Future<bool> load({
    String? unitId,
    bool force = false,

    /// The timeout of this ad. If null, defaults to 1 minute
    Duration? timeout,

    /// Whether non-personalized ads should be enabled
    bool? nonPersonalizedAds,

    /// The keywords of the ad
    List<String> keywords = const [],
  }) async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    if (!debugCheckAdWillReload(isAvailable, force)) return false;
    isLoaded = (await channel.invokeMethod<bool>('loadAd', {
      'unitId': unitId ??
          this.unitId ??
          MobileAds.interstitialAdUnitId ??
          MobileAds.interstitialAdTestUnitId,
      'nonPersonalizedAds': nonPersonalizedAds ?? this.nonPersonalizedAds,
      'keywords': keywords,
    }).timeout(
      timeout ?? this.loadTimeout,
      onTimeout: () {
        if (!onEventController.isClosed && !isLoaded)
          onEventController.add({
            FullScreenAdEvent.loadFailed: AdError.timeoutError,
          });
        return false;
      },
    ))!;
    if (isLoaded) lastLoadedTime = DateTime.now();
    return isLoaded;
  }

  /// Show the interstitial ad. This returns a `Future` that will complete when
  /// the ad gets closed
  ///
  /// The ad must be loaded. To check if the ad is loaded, call
  /// `interstitialAd.isLoaded`. If it's not loaded, throws an `AssertionError`
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#show-the-ad)
  Future<bool> show() async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    ensureAdAvailable();
    return (await channel.invokeMethod<bool>('show'))!;
  }
}
