import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';

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

class InterstitialAd {
  final _key = UniqueKey();

  /// The unique id of the controller
  String get id => _key.toString();

  final _onEvent =
      StreamController<Map<InterstitialAdEvent, dynamic>>.broadcast();

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
  Stream<Map<InterstitialAdEvent, dynamic>> get onEvent => _onEvent.stream;

  /// Channel to communicate with plugin
  final _pluginChannel = const MethodChannel("native_admob_flutter");

  /// Channel to communicate with controller
  MethodChannel _channel;

  bool _loaded = false;

  /// Returns true if the ad was successfully loaded and is ready to be shown.
  bool get isLoaded => _loaded;

  /// Creates a new native ad controller
  InterstitialAd([String unitId]) {
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);

    // Let the plugin know there is a new controller
    _init(unitId);
  }

  /// Initialize the controller. This can be called only by the controller
  void _init(String unitId) {
    final uId = unitId ??
        MobileAds.interstitialAdUnitId ??
        MobileAds.interstitialAdTestUnitId;
    assert(uId != null);
    _pluginChannel.invokeMethod("initInterstitialAd", {
      "id": id,
      "unitId": uId,
    });
  }

  /// Dispose the controller. Once disposed, the controller can not be used anymore
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   super.dispose();
  ///   controller?.dispose();
  /// }
  /// ```
  void dispose() {
    _pluginChannel.invokeMethod("disposeInterstitialAd", {"id": id});
    _onEvent.close();
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "loading":
        _onEvent.add({InterstitialAdEvent.loading: null});
        break;
      case "onAdFailedToLoad":
        _onEvent
            .add({InterstitialAdEvent.loadFailed: call.arguments['errorCode']});
        break;
      case "onAdLoaded":
        _loaded = true;
        _onEvent.add({InterstitialAdEvent.loaded: null});
        break;
      case "onAdClicked":
        _onEvent.add({InterstitialAdEvent.clicked: null});
        break;
      case "onAdOpened":
        _onEvent.add({InterstitialAdEvent.opened: null});
        break;
      case "onAdClosed":
        _loaded = false;
        _onEvent.add({InterstitialAdEvent.closed: null});
        break;
      case "onAdLeftApplication":
        _onEvent.add({InterstitialAdEvent.leftApplication: null});
        break;
      case 'undefined':
      default:
        _onEvent.add({InterstitialAdEvent.undefined: null});
        break;
    }
  }

  /// Load the ad.
  Future<void> load() async {
    // assert(
    //   MobileAds.isInitialized,
    //   'You MUST initialize the ADMOB before requesting any ads',
    // );
    await _channel.invokeMethod('loadAd', null);
  }

  /// Show the interstitial ad.
  ///
  /// The ad must be loaded. To check if the ad is loaded, call
  /// `controller.isLoaded`. If it's not loaded, throws an `AssertionError`
  void show() {
    assert(
      isLoaded,
      """
      The ad must be loaded to show. 
      Call controller.load() to load the ad. 
      Call controller.isLoaded to check if the ad is loaded before showing.
      """,
    );
    _channel.invokeMethod('show');
  }

  /// Request the UI to update when changes happen. This is used for
  /// dynamically changing the layout (by hot reload or setState)
  void requestAdUIUpdate(Map<String, dynamic> layout) {
    // print('requested ui update');
    _channel.invokeMethod('updateUI', {'layout': layout ?? {}});
  }

  /// Mutes This Ad programmatically.
  ///
  /// Use null to Mute This Ad with default reason.
  void muteThisAd([int reason]) {
    _channel.invokeMethod('muteAd', {'reason': reason});
  }
}
