import 'dart:async';

import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';
import '../utils.dart';

/// The events a [RewardedAd] can receive. Listen
/// to the events using `rewardedAd.onEvent.listen((event) {})`.
///
/// Avaiable events:
///   - loading (When the ad starts loading)
///   - loaded (When the ad is loaded)
///   - loadFailed (When the ad failed to load)
///   - opened (When the ad is opened)
///   - showFailed (When the ad failed to show)
///   - undefined (When it receives an unknown error)
enum RewardedAdEvent {
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

  /// Called when the ad opens
  opened,

  /// Called when the ad closes
  closed,

  /// Called when the user earns an reward
  earnedReward,

  /// Called when the ad failed to show
  showFailed,
}

class RewardItem {
  /// Returns the reward amount.
  int amount;

  /// Returns the type of the reward.
  String type;

  RewardItem({this.amount, this.type});

  @override
  String toString() => '$amount $type';

  factory RewardItem.fromJson(Map j) {
    return RewardItem(amount: j['amount'], type: j['type']);
  }
}

/// An InterstitialAd model to communicate with the model on the platform side.
/// It gives you methods to help in the implementation and event tracking.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/rewarded-fullscreen
///   - https://developers.google.com/admob/ios/rewarded-ads
class RewardedAd extends LoadShowAd<RewardedAdEvent> {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/5224354917
  ///   - iOS: ca-app-pub-3940256099942544/1712485313
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get testUnitId => MobileAds.rewardedAdTestUnitId;

  /// Create and load a new ad without extra code.\
  /// **WARNING** Do NOT use this if it needs to be fast. If it does, use [pre-loading](https://github.com/bdlukaa/native_admob_flutter/wiki/Pre-load-a-rewarded-ad)
  ///
  /// Usage:
  /// ```dart
  /// await (await createAndLoad()).show();
  /// ```
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-ad#using-rewarded-ads-more-than-once)
  static Future<RewardedAd> createAndLoad([String unitId]) async {
    final ad = RewardedAd(unitId);
    await ad.load();
    return ad;
  }

  /// Listen to the events the ad throws
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
  ///       final errorCode = e.values.first;
  ///       print('load failed $errorCode');
  ///       break;
  ///     case RewardedAdEvent.opened:
  ///       print('ad opened');
  ///       break;
  ///     case RewardedAdEvent.closed:
  ///       print('ad closed');
  ///       break;
  ///     case RewardedAdEvent.earnedReward:
  ///       final reward = e.values.first;
  ///       print('earned reward: $reward');
  ///       break;
  ///     case RewardedAdEvent.showFailed:
  ///       final errorCode = e.values.first;
  ///       print('show failed $errorCode');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-ad#listening-to-events)
  Stream<Map<RewardedAdEvent, dynamic>> get onEvent => super.onEvent;

  RewardItem _item;
  RewardItem get item => _item;

  bool _loaded = false;

  /// Returns true if the ad was successfully loaded and is ready to be shown.
  bool get isLoaded => _loaded;

  final String unitId;

  /// Creates a new native ad controller
  RewardedAd([this.unitId]) : super();

  /// Initialize the controller. This can be called only by the controller
  void init() async {
    channel.setMethodCallHandler(_handleMessages);
    final uId =
        unitId ?? MobileAds.rewardedAdUnitId ?? MobileAds.rewardedAdTestUnitId;
    assert(uId != null);
    final reward =
        await MobileAds.pluginChannel.invokeMethod('initRewardedAd', {
      'id': id,
      'unitId': uId,
    });
    _item = RewardItem.fromJson(reward);
  }

  /// Dispose the ad to free up resources.
  /// Once disposed, this ad can not be used anymore.
  ///
  /// The ad gets disposed automatically when closed, so you do NOT
  /// need to worry about it.
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
    MobileAds.pluginChannel.invokeMethod('disposeRewardedAd', {'id': id});
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'loading':
        onEventController.add({RewardedAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        onEventController.add(
            {RewardedAdEvent.loadFailed: AdError.fromJson(call.arguments)});
        break;
      case 'onAdLoaded':
        onEventController.add({RewardedAdEvent.loaded: null});
        break;
      case 'onRewardedAdOpened':
        onEventController.add({RewardedAdEvent.opened: null});
        break;
      case 'onRewardedAdClosed':
        onEventController.add({RewardedAdEvent.closed: null});
        dispose();
        break;
      case 'onUserEarnedReward':
        onEventController.add({
          RewardedAdEvent.earnedReward: RewardItem.fromJson(call.arguments)
        });
        break;
      case 'onRewardedAdFailedToShow':
        onEventController.add(
            {RewardedAdEvent.showFailed: AdError.fromJson(call.arguments)});
        break;
      case 'undefined':
      default:
        onEventController.add({RewardedAdEvent.undefined: null});
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
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-ad#load-the-ad)
  Future<bool> load() async {
    assertMobileAdsIsInitialized();
    _loaded = await channel.invokeMethod<bool>('loadAd', null);
    return _loaded;
  }

  /// Show the rewarded ad. This returns a `Future` that will complete when
  /// the ad gets closed
  ///
  /// The ad must be loaded. To check if the ad is loaded, call
  /// `rewardedAd.isLoaded`. If it's not loaded, throws an `AssertionError`
  ///
  /// This can be shown only once. If you try to show it more than once,
  /// it'll fail. If you `need` to show it more than once, read
  /// [this](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-rewarded-ad#using-rewarded-ads-more-than-once)
  ///
  /// Usage
  /// ```dart
  /// print('showing the ad');
  /// await (await rewardedAd.load()).show();
  /// print('ad showed');
  /// ```
  Future<bool> show() {
    assert(
      isLoaded,
      '''The ad must be loaded to show. 
      Call controller.load() to load the ad. 
      Call controller.isLoaded to check if the ad is loaded before showing.''',
    );
    return channel.invokeMethod<bool>('show');
  }
}
