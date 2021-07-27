import 'dart:async';

import 'package:flutter/services.dart';

import '../../../native_admob_flutter.dart';
import '../../utils.dart';
import 'media_content.dart';
import 'options.dart';

export 'media_content.dart';
export 'options.dart';

/// The events a [NativeAdController] can receive. Listen
/// to the events using `controller.onEvent.listen((event) {})`.
///
/// Avaiable events:
///   - loading (When the ad starts loading)
///   - loaded (When the ad is loaded)
///   - loadFailed (When the ad failed to load)
///   - muted (When the ad is dismissed)
///   - undefined (When it receives an unknown error)
///
/// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#listen-to-events)
enum NativeAdEvent {
  /// Called when an ad request failed.
  ///
  /// You can see the error codes [here](https://github.com/bdlukaa/native_admob_flutter/wiki/Ad-error-codes#common-error-codes)
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#reloading-the-ad)
  loadFailed,

  /// Called when an ad is received.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#reloading-the-ad)
  loaded,

  /// Called when the ad starts loading
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#reloading-the-ad)
  loading,

  /// Called when the ad is muted, in other words, when the user closes the ad
  ///
  /// ![Default mute this ad](https://developers.google.com/admob/images/mute-this-ad.png)
  ///
  /// If you don't want to use the default `mute this ad`,
  /// read the documentation on [how to create a custom mute this ad](https://github.com/bdlukaa/native_admob_flutter/wiki/Custom-mute-this-ad)
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
///   - muted (When the video is muted)
///   - unmuted (When the video is unmuted)
///
/// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#listen-to-video-events)
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

  /// Called when the video is muted
  muted,

  /// Called when the video is unmuted
  unmuted,
}

/// An Native Ad Controller model to communicate with the model on the platform side.
/// It gives you methods to help in the implementation and event tracking.
/// It's supposed to work alongside `NativeAd`, the class used to show the ad in
/// the UI and add it to the widget tree.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/native/start
///   - https://developers.google.com/admob/ios/native/start
class NativeAdController extends LoadShowAd<NativeAdEvent>
    with AttachableMixin {
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

  MediaContent? _mediaContent;

  /// Provides media content information.
  ///
  /// This will be null until load is complete
  MediaContent? get mediaContent => _mediaContent;

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
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Custom-mute-this-ad#check-if-custom-mute-this-ad-is-available)
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
  ///     case AdVideoEvent.muted;
  ///       print('video muted');
  ///       break;
  ///     case AdVideoEvent.unmuted;
  ///       print('video unmuted');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#listen-to-video-events)
  Stream<Map<AdVideoEvent, dynamic>> get onVideoEvent => _onVideoEvent.stream;

  /// Check if the controller is attached to a `NativeAd`
  bool get isAttached => super.isAttached;

  String? _headline;
  String? _body;
  String? _price;
  String? _store;
  String? _callToAction;
  String? _advertiser;
  String? _iconUri;
  List<String>? _imagesUri;

  /// The title text of the ad. If [isAvailable] is true,
  /// this is always non-null.
  String? get headline => _headline;

  /// The body text of the ad. If [isAvailable] is true,
  /// this is always non-null.
  String? get body => _body;

  /// The price of the product announced on the ad. This
  /// may be null even if [isAvailable] is true.
  String? get price => _price;

  /// The store that is announcing the product on the ad.
  /// This may be null even if [isAvailable] is true.
  String? get store => _store;

  /// The text of the button. If [isAvailable] is true,
  /// this is always non-null.
  String? get callToAction => _callToAction;

  /// The advertiser that is announcing the ad. This
  /// may be null even if [isAvailable] is true.
  String? get advertiser => _advertiser;

  /// The url of the icon image. This may be null even if
  /// [isAvailable] is true.
  String? get iconUri => _iconUri;

  /// The urls of the media. If [isAvailable] is true, this
  /// is always non-null.
  List<String>? get imagesUri => _imagesUri;

  /// Creates a new native ad controller
  NativeAdController({
    String? unitId,
    Duration loadTimeout = kDefaultLoadTimeout,
    Duration timeout = kDefaultAdTimeout,
  }) : super(
          loadTimeout: loadTimeout,
          timeout: timeout,
          unitId: unitId,
        );

  /// Initialize the controller. This can be called only by the controller
  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initNativeAdController', {'id': id});
  }

  /// Dispose the controller to free up resources.
  /// Once disposed, the controller can not be used anymore.
  /// If you try to use a disposed controller, an `AssertionError`
  /// is thrown
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
    MobileAds.pluginChannel.invokeMethod('disposeNativeAdController', {
      'id': id,
    });
    _onVideoEvent.close();
    attach(false);
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
          bool isMuted = call.arguments;
          if (isMuted)
            _onVideoEvent.add({AdVideoEvent.muted: null});
          else
            _onVideoEvent.add({AdVideoEvent.unmuted: null});
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
        isLoaded = false;
        onEventController.add({NativeAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        isLoaded = false;
        onEventController.add({
          NativeAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdLoaded':
        isLoaded = true;
        final arguments = call.arguments! as Map;
        arguments.forEach((key, value) {
          final args = value;
          switch (key) {
            case 'mediaContent':
              _mediaContent = MediaContent.fromJson(args);
              break;
            case 'adDetails':
              final _adDetails = (args as Map).cast<String, dynamic>();
              _headline = _adDetails['headline'];
              _body = _adDetails['body'];
              _price = _adDetails['price'];
              _store = _adDetails['store'];
              _callToAction = _adDetails['callToAction'];
              _advertiser = _adDetails['advertiser'];
              _iconUri = _adDetails['iconUri'];
              _imagesUri = List<String>.from(_adDetails['imagesUri']);
              break;
            case 'muteThisAdInfo':
              _muteThisAdReasons =
                  (args['muteThisAdReasons'] as List).cast<String>();
              _customMuteThisAdEnabled =
                  args['isCustomMuteThisAdEnabled'] as bool;
              return;
            default:
              break;
          }
        });
        onEventController.add({NativeAdEvent.loaded: null});
        break;
      case 'onAdMuted':
        onEventController.add({NativeAdEvent.muted: null});
        break;
      case 'undefined':
      default:
        onEventController.add({NativeAdEvent.undefined: null});
        break;
    }
  }

  /// Load the ad. If the controller is disposed or the Mobile Ads SDK
  /// (ADMOB SDK) is not initialized, an `AssertionError` is thrown.
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events#reloading-the-ad)
  Future<bool> load({
    /// The ad unit id. If null, uses [MobileAds.nativeAdUnitId]
    String? unitId,
    NativeAdOptions? options,

    /// Force to load an ad even if another is already avaiable
    bool force = false,

    /// The timeout of this ad. If null, defaults to 1 minute
    Duration? timeout,

    /// Whether non-personalized ads (ads that are not based on a user’s past behavior) should be enabled.
    bool? nonPersonalizedAds,

    /// {@macro ads.keywords}
    List<String> keywords = const [],
  }) async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    if (!debugCheckAdWillReload(isLoaded, force)) return false;
    unitId ??= MobileAds.nativeAdUnitId ?? MobileAds.nativeAdTestUnitId;
    isLoaded = (await channel.invokeMethod<bool>('loadAd', {
      'unitId': unitId,
      'options': (options ?? NativeAdOptions()).toJson(),
      'nonPersonalizedAds': nonPersonalizedAds ?? this.nonPersonalizedAds,
      'keywords': keywords,
    }).timeout(
      timeout ?? this.loadTimeout,
      onTimeout: () {
        if (!onEventController.isClosed && !isLoaded)
          onEventController.add({
            NativeAdEvent.loadFailed: AdError.timeoutError,
          });
        return false;
      },
    ))!;
    if (isLoaded) lastLoadedTime = DateTime.now();
    return isLoaded;
  }

  /// Mutes This Ad programmatically.
  ///
  /// Use `null` to Mute This Ad with default reason.
  ///
  /// [reason], if non-null, mustn't be negative, otherwise an
  /// [AssertionError] is thrown.
  ///
  /// Fore more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Custom-mute-this-ad)
  Future<void> muteThisAd([int? reason]) {
    ensureAdNotDisposed();
    if (reason != null)
      assert(!reason.isNegative, 'You must specify a valid reason');
    return channel.invokeMethod('muteAd', {'reason': reason});
  }
}
