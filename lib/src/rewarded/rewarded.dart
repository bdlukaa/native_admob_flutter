import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';

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

  factory RewardItem.fromJson(Map j) {
    return RewardItem(
      amount: j['amount'],
      type: j['type'],
    );
  }
}

class RewardedAd {
  /// Create and load a new ad without extra code.\
  /// #### Do NOT use this if it needs to be fast. If it does, use [pre-loading](https://github.com/bdlukaa/native_admob_flutter/wiki/Pre-load-a-rewarded-ad)
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

  final _key = UniqueKey();

  /// The unique id of the controller
  String get id => _key.toString();

  final _onEvent = StreamController<Map<RewardedAdEvent, dynamic>>.broadcast();

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
  Stream<Map<RewardedAdEvent, dynamic>> get onEvent => _onEvent.stream;

  RewardItem _item;
  RewardItem get item => _item;

  /// Channel to communicate with plugin
  final _pluginChannel = const MethodChannel('native_admob_flutter');

  /// Channel to communicate with controller
  MethodChannel _channel;

  bool _loaded = false;

  /// Returns true if the ad was successfully loaded and is ready to be shown.
  bool get isLoaded => _loaded;

  /// Creates a new native ad controller
  RewardedAd([String unitId]) {
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);

    // Let the plugin know there is a new controller
    _init(unitId);
  }

  /// Initialize the controller. This can be called only by the controller
  void _init(String unitId) async {
    final uId =
        unitId ?? MobileAds.rewardedAdUnitId ?? MobileAds.rewardedAdTestUnitId;
    assert(uId != null);
    final reward = await _pluginChannel.invokeMethod('initRewardedAd', {
      'id': id,
      'unitId': uId,
    });
    _item = RewardItem.fromJson(reward);
  }

  /// Dispose the ad. Once disposed, this ad can not be used anymore.
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
    _pluginChannel.invokeMethod('disposeRewardedAd', {'id': id});
    _onEvent.close();
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'loading':
        _onEvent.add({RewardedAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        _onEvent.add(
            {RewardedAdEvent.loadFailed: AdError.fromJson(call.arguments)});
        break;
      case 'onAdLoaded':
        _onEvent.add({RewardedAdEvent.loaded: null});
        break;
      case 'onRewardedAdOpened':
        _onEvent.add({RewardedAdEvent.opened: null});
        break;
      case 'onRewardedAdClosed':
        _onEvent.add({RewardedAdEvent.closed: null});
        dispose();
        break;
      case 'onUserEarnedReward':
        _onEvent.add({
          RewardedAdEvent.earnedReward: RewardItem.fromJson(call.arguments)
        });
        break;
      case 'onRewardedAdFailedToShow':
        _onEvent.add(
            {RewardedAdEvent.showFailed: AdError.fromJson(call.arguments)});
        break;
      case 'undefined':
      default:
        _onEvent.add({RewardedAdEvent.undefined: null});
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
  Future<void> load() async {
    // assert(
    //   MobileAds.isInitialized,
    //   'You MUST initialize the ADMOB before requesting any ads',
    // );
    _loaded = await _channel.invokeMethod<bool>('loadAd', null);
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
  Future<void> show() {
    assert(
      isLoaded,
      '''The ad must be loaded to show. 
      Call controller.load() to load the ad. 
      Call controller.isLoaded to check if the ad is loaded before showing.''',
    );
    return _channel.invokeMethod('show');
  }
}
