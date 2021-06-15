import 'dart:async';

import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';
import '../utils.dart';

/// A RewardedInterstitialAd model to communicate with the model on the platform side.
/// It gives you methods to help in the implementation and event tracking.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/rewarded-interstitial
///   - https://developers.google.com/admob/ios/rewarded-interstitial
class RewardedInterstitialAd extends LoadShowAd<RewardedAdEvent> {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/5354046379
  ///   - iOS: ca-app-pub-3940256099942544/6978759866
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get testUnitId => MobileAds.rewardedInterstitialAdTestUnitId;

  /// Listen to the events thís ad throws
  ///
  /// Usage:
  /// ```dart
  /// ad.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case RewardedAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case RewardedAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case RewardedAdEvent.loadFailed:
  ///       final error = e.values.first;
  ///       print('load failed $error');
  ///       break;
  ///     case RewardedAdEvent.showed:
  ///       print('ad showed');
  ///       break;
  ///     case RewardedAdEvent.showFailed:
  ///       final error = e.values.first;
  ///       print('show failed $error');
  ///       break;
  ///     case RewardedAdEvent.closed:
  ///       print('ad closed');
  ///       break;
  ///     case RewardedAdEvent.earnedReward:
  ///       final reward = e.values.first;
  ///       print('earned reward: $reward');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-interstitial-ad#listening-to-events)
  Stream<Map<RewardedAdEvent, dynamic>> get onEvent => super.onEvent;

  /// Creates a new Rewarded Intersitital Ad
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-interstitial-ad#create-a-rewarded-ad)
  RewardedInterstitialAd({
    String? unitId,
    Duration loadTimeout = kDefaultLoadTimeout,
    Duration timeout = kDefaultAdTimeout,
    bool nonPersonalizedAds = kDefaultNonPersonalizedAds,
    ServerSideVerificationOptions? serverSideVerificationOptions =
        kServerSideVerification,
  }) : super(
          unitId: unitId,
          loadTimeout: loadTimeout,
          timeout: timeout,
          nonPersonalizedAds: nonPersonalizedAds,
          serverSideVerificationOptions: serverSideVerificationOptions,
        );

  /// Initialize the ad. This can be called only by the ad
  void init() async {
    channel.setMethodCallHandler(_handleMessages);
    await MobileAds.pluginChannel.invokeMethod('initRewardedInterstitialAd', {
      'id': id,
    });
  }

  /// Dispose the ad to free up resources.
  /// Once disposed, this ad can not be used anymore.
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   super.dispose();
  ///   rewardedAd?.dispose();
  /// }
  /// ```
  void dispose() {
    super.dispose();
    MobileAds.pluginChannel.invokeMethod('disposeRewardedInterstitialAd', {
      'id': id,
    });
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    switch (call.method) {
      case 'loading':
        onEventController.add({RewardedAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        isLoaded = false;
        onEventController.add({
          RewardedAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdLoaded':
        isLoaded = true;
        onEventController.add({RewardedAdEvent.loaded: null});
        break;
      case 'onUserEarnedReward':
        onEventController.add({
          RewardedAdEvent.earnedReward: RewardItem.fromJson(call.arguments)
        });
        break;
      case 'onAdShowedFullScreenContent':
        isLoaded = false;
        onEventController.add({RewardedAdEvent.showed: null});
        break;
      case 'onAdFailedToShowFullScreenContent':
        onEventController.add({
          RewardedAdEvent.showFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdDismissedFullScreenContent':
        onEventController.add({RewardedAdEvent.closed: null});
        break;
      default:
        break;
    }
  }

  /// Load the ad. The ad must be loaded so it can be shown.
  /// You can verify if the ad is loaded calling `rewardedAd.isLoaded`
  ///
  /// Usage:
  /// ```dart
  /// (await rewardedAd.load());
  /// if (rewardedAd.isLoaded) rewardedAd.show();
  /// ```
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-interstitial-ad#load-the-ad)
  Future<bool> load(
      {

      /// The ad unit id. If null, uses [MobileAds.rewardedAdUnitId]
      String? unitId,

      /// Force to load an ad even if another is already avaiable
      bool force = false,

      /// The timeout of this ad. If null, defaults to 1 minute
      Duration? timeout,

      /// Whether non-personalized ads should be enabled
      bool? nonPersonalizedAds,

      /// The keywords of the ad
      List<String> keywords = const [],

      ///SSV Info - Such as userId and customData
      ServerSideVerificationOptions? serverSideVerificationOptions}) async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    if (!debugCheckAdWillReload(isLoaded, force)) return false;
    isLoaded = (await channel.invokeMethod<bool>('loadAd', {
      'unitId': unitId ??
          this.unitId ??
          MobileAds.rewardedAdUnitId ??
          MobileAds.rewardedAdTestUnitId,
      'nonPersonalizedAds': nonPersonalizedAds ?? this.nonPersonalizedAds,
      'keywords': keywords,
      'ssv': serverSideVerificationOptions?.toJson()
    }).timeout(
      timeout ?? this.loadTimeout,
      onTimeout: () {
        if (!onEventController.isClosed && !isLoaded)
          onEventController.add({
            RewardedAdEvent.loadFailed: AdError.timeoutError,
          });
        return false;
      },
    ))!;
    if (isLoaded) lastLoadedTime = DateTime.now();
    return isLoaded;
  }

  /// Show the rewarded ad. This returns a `Future` that will complete when
  /// the ad gets closed
  ///
  /// The ad must be loaded. To check if the ad is loaded, call
  /// `rewardedAd.isLoaded`. If it's not loaded, throws an `AssertionError`
  ///
  /// This can be shown only once. If you try to show it more than once,
  /// it'll fail. If you `need` to show it more than once, read
  /// [this](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-interstitial-ad#using-rewarded-ads-more-than-once)
  ///
  /// Usage
  /// ```dart
  /// print('showing the ad');
  /// await (await rewardedAd.load()).show();
  /// print('ad showed');
  /// ```
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-interstitial-ad#show-the-ad)
  Future<bool> show() async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    ensureAdAvailable();
    return (await channel.invokeMethod<bool>('showAd'))!;
  }
}
