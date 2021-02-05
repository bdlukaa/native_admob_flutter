import 'dart:async';

import 'package:flutter/services.dart';

import '../../../native_admob_flutter.dart';
import '../../utils.dart';
import 'options.dart';
import 'media_content.dart';

export 'options.dart';
export 'media_content.dart';

/// The events a [NativeAdController] can receive. Listen
/// to the events using `controller.onEvent.listen((event) {})`.
///
/// Avaiable events:
///   - loading (When the ad starts loading)
///   - loaded (When the ad is loaded)
///   - loadFailed (When the ad failed to load)
///   - impression (When the ad is rendered)
///   - clicked (When the ad is clicked by the user)
///   - muted (When the ad is dismissed)
///   - undefined (When it receives an unknown error)
enum NativeAdEvent {
  /// Called when an impression is recorded for an ad.
  impression,

  /// Called when a click is recorded for an ad.
  clicked,

  /// Called when an ad request failed.
  loadFailed,

  /// Called when an ad is received.
  loaded,

  /// Called when the ad starts loading
  loading,
  muted,

  /// Called when the event is unkown (usually for rebuilding ui)
  undefined,
}

/// The video events a [NativeAdController] can receive. Listen
/// to the events using `controller.onVideoEvent.listen((event) {})`.
///
/// Avaiable events:
///   - start (When the video starts)
///   - play (When the video is played)
///   - pause (When the video is paused)
///   - end (When the avideo reaches the end)
///   - mute (When the video is muted)
enum AdVideoEvent {
  /// Called when the video starts. This is called only once
  start,

  /// Called when the video is played. This can be called multiple times
  /// while the video is running
  play,

  /// Called when the video is somehow paused, either for user interaction
  /// or programatically
  pause,

  /// Called when the video reaches the end
  end,

  /// Called when the video is somhow muted, either for user interaction
  /// or programatically
  mute,
}

/// An Native Ad Controller model to communicate with the model on the platform side.
/// It gives you methods to help in the implementation and event tracking.
/// It's supposed to work alongside `NativeAd`, the class used to show the ad in
/// the UI and add it to the widget tree.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/native/start
///   - https://developers.google.com/admob/ios/native/start
class NativeAdController extends LoadShowAd<NativeAdEvent> {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/2247696110
  ///   - iOS: ca-app-pub-3940256099942544/3986624511
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get testUnitId => MobileAds.nativeAdTestUnitId;

  /// The video test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/1044960115
  ///   - iOS: ca-app-pub-3940256099942544/2521693316
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get videoTestUnitId => MobileAds.nativeAdVideoTestUnitId;

  MediaContent _mediaContent;

  /// Provides media content information.
  ///
  /// This will be null until load is complete
  MediaContent get mediaContent => _mediaContent;

  List<String> _muteThisAdReasons = [];

  /// Returns Mute This Ad reasons available for this ad. Use
  /// these `String`s for showing the user
  List<String> get muteThisAdReasons => _muteThisAdReasons;

  bool _customMuteThisAdEnabled = false;

  /// Returns true if this ad can be muted programmatically.
  /// Use `NativeAdOptions` when loading the ad to request
  /// custom implementation of Mute This Ad.
  ///
  /// Use `options` in `NativeAd` to enable Custom Mute This Ad
  bool get isCustomMuteThisAdEnabled => _customMuteThisAdEnabled;

  /// Listen to the events the controller throws
  ///
  /// Usage:
  /// ```dart
  /// controller.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case NativeAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case NativeAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case NativeAdEvent.loadFailed:
  ///       final errorCode = e.values.first;
  ///       print('loadFailed $errorCode');
  ///       break;
  ///     case NativeAdEvent.impression:
  ///       print('ad rendered');
  ///       break;
  ///     case NativeAdEvent.clicked;
  ///       print('clicked');
  ///       break;
  ///     case NativeAdEvent.muted:
  ///       showDialog(
  ///         ...,
  ///         builder: (_) => AlertDialog(title: Text('Ad muted')),
  ///       );
  ///       break
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#listen-to-events)
  Stream<Map<NativeAdEvent, dynamic>> get onEvent => super.onEvent;

  final _onVideoEvent =
      StreamController<Map<AdVideoEvent, dynamic>>.broadcast();

  /// Listen to the video events the controller throws
  ///
  /// Usage:
  /// ```dart
  /// controller.onVideoEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case AdVideoEvent.start:
  ///       print('video started');
  ///       break;
  ///     case NativeAdEvent.play:
  ///       print('video played');
  ///       break;
  ///     case AdVideoEvent.pause:
  ///       print('video paused');
  ///       break;
  ///     case AdVideoEvent.end:
  ///       print('video finished');
  ///       break;
  ///     case AdVideoEvent.mute;
  ///       print('video muted');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#listen-to-video-events)
  Stream<Map<AdVideoEvent, dynamic>> get onVideoEvent => _onVideoEvent.stream;

  bool _attached = false;

  /// Check if the controller is attached to a `NativeAd`
  bool get isAttached => _attached;

  /// Creates a new native ad controller
  NativeAdController() : super();

  /// Initialize the controller. This can be called only by the controller
  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initNativeAdController', {'id': id});
  }

  /// Attach the controller to a new `BannerAd`. Throws an `AssertionException` if the controller
  /// is already attached.
  ///
  /// You should NOT call this function
  void attach() {
    assertControllerIsNotAttached(isAttached);
    _attached = true;
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
    super.dispose();
    MobileAds.pluginChannel.invokeMethod(
      'disposeNativeAdController',
      {'id': id},
    );
    _onVideoEvent.close();
    _attached = false;
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    if (call.method.startsWith('onVideo')) {
      switch (call.method) {
        case 'onVideoStart':
          _onVideoEvent.add({AdVideoEvent.start: null});
          break;
        case 'onVideoPlay':
          _onVideoEvent.add({AdVideoEvent.play: null});
          break;
        case 'onVideoPause':
          _onVideoEvent.add({AdVideoEvent.pause: null});
          break;
        case 'onVideoMute':
          _onVideoEvent.add({AdVideoEvent.mute: null});
          break;
        case 'onVideoEnd':
          _onVideoEvent.add({AdVideoEvent.end: null});
          break;
        default:
          break;
      }
      return;
    }
    switch (call.method) {
      case 'loading':
        onEventController.add({NativeAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        onEventController
            .add({NativeAdEvent.loadFailed: AdError.fromJson(call.arguments)});
        break;
      case 'onAdLoaded':
        onEventController.add({NativeAdEvent.loaded: null});
        break;
      case 'onAdClicked':
        onEventController.add({NativeAdEvent.clicked: null});
        break;
      case 'onAdImpression':
        onEventController.add({NativeAdEvent.impression: null});
        break;
      case 'onAdMuted':
        onEventController.add({NativeAdEvent.muted: null});
        break;
      case 'undefined':
      default:
        onEventController.add({NativeAdEvent.undefined: null});
        break;
    }

    if (call.arguments != null && call.arguments is Map) {
      (call.arguments as Map).forEach((key, value) {
        switch (key) {
          case 'muteThisAdInfo':
            final Map args = (value ?? {}) as Map;
            _muteThisAdReasons = args?.get('muteThisAdReasons') ?? [];
            _customMuteThisAdEnabled =
                args?.get('isCustomMuteThisAdEnabled') ?? false;
            break;
          case 'mediaContent':
            _mediaContent = MediaContent.fromJson(value);
            break;
          default:
            break;
        }
      });
    }
  }

  /// Load the ad. If the controller is disposed or not attached,
  /// or the Mobile Ads SDK (ADMOB SDK) is not initialized,
  /// an `AssertionError` is thrown.
  ///
  /// If [unitId] is not specified, uses [MobileAds.nativeAdUnitId]
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#reloading-the-ad)
  Future<bool> load({String unitId, NativeAdOptions options}) {
    assertControllerIsAttached(isAttached);
    assertMobileAdsIsInitialized();
    // The id will never be null, so you don't need to check
    unitId ??= MobileAds.nativeAdUnitId ?? MobileAds.nativeAdTestUnitId;
    return channel.invokeMethod<bool>('loadAd', {
      'unitId': unitId,
      'options': (options ?? NativeAdOptions()).toJson(),
    });
  }

  /// Request the UI to update when changes happen. This is used for
  /// dynamically changing the layout (by hot reload or setState)
  ///
  /// You'll rarely need to call this method
  void requestAdUIUpdate(Map<String, dynamic> layout) {
    // print('requested ui update');
    channel.invokeMethod('updateUI', {'layout': layout ?? {}});
  }

  /// Mutes This Ad programmatically.
  ///
  /// Use null to Mute This Ad with default reason.
  ///
  /// Fore more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Custom-mute-this-ad)
  void muteThisAd([int reason]) {
    assert(
      isAttached,
      'You can NOT use a disposed controller',
    );
    channel.invokeMethod('muteAd', {'reason': reason});
  }
}

extension _map<K, V> on Map<K, V> {
  V get(K key) {
    if (containsKey(key)) return this[key];
    return null;
  }
}
