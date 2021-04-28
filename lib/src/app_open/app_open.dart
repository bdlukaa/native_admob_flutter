import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../events.dart';
import '../mobile_ads.dart';
import '../utils.dart';

/// An AppOpenAd model to communicate with the model in the platform side.
/// It gives you methods to help in the implementation and event tracking.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/app-open-ads
///   - https://developers.google.com/admob/ios/app-open-ads
class AppOpenAd extends LoadShowAd<FullScreenAdEvent> {
  /// Portrait orientation
  static const int ORIENTATION_PORTRAIT = 1;

  /// Landscape orientation
  static const int ORIENTATION_LANDSCAPE = 2;

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

  bool _isShowing = false;

  /// Check if the ad is currently on the screen or not.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#show-the-ad)
  bool get isShowing => _isShowing;

  /// Creates a new AppOpenAd instance.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#creating-an-ad-object)
  AppOpenAd({
    Duration loadTimeout = kDefaultLoadTimeout,
    Duration timeout = kDefaultAdTimeout,
    String? unitId,
    bool nonPersonalizedAds = kDefaultNonPersonalizedAds,
  }) : super(
          unitId: unitId,
          loadTimeout: loadTimeout,
          timeout: timeout,
          nonPersonalizedAds: nonPersonalizedAds,
        );

  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initAppOpenAd', {'id': id});
  }

  Future<void> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    switch (call.method) {
      case 'loading':
        isLoaded = false;
        onEventController.add({FullScreenAdEvent.loading: null});
        break;
      case 'onAppOpenAdFailedToLoad':
        isLoaded = false;
        onEventController.add({
          FullScreenAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAppOpenAdLoaded':
        isLoaded = true;
        onEventController.add({FullScreenAdEvent.loaded: null});
        break;
      case 'onAdDismissedFullScreenContent':
        isLoaded = false;
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
    String? unitId,

    /// The orientation. Avaiable orientations:\
    /// 1 - [ORIENTATION_PORTRAIT]\
    /// 2 - [ORIENTATION_LANDSCAPE]\
    ///
    /// If null, defaults to the current device orientation
    int? orientation,

    /// Force to load an ad even if another is already avaiable
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
    if (!debugCheckAdWillReload(isLoaded, force)) return false;
    if (orientation != null) {
      assert(
        [ORIENTATION_PORTRAIT, ORIENTATION_LANDSCAPE].contains(orientation),
        'The orientation must be a valid orientation: $ORIENTATION_PORTRAIT, $ORIENTATION_LANDSCAPE',
      );
    } else {
      final window = WidgetsBinding.instance!.window;
      final size = window.physicalSize / window.devicePixelRatio;
      final deviceOrientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;

      switch (deviceOrientation) {
        case Orientation.landscape:
          orientation = ORIENTATION_LANDSCAPE;
          break;
        case Orientation.portrait:
          orientation = ORIENTATION_PORTRAIT;
          break;
      }
    }
    final bool loaded = (await channel.invokeMethod<bool>('loadAd', {
      'unitId': unitId ??
          this.unitId ??
          MobileAds.appOpenAdUnitId ??
          MobileAds.appOpenAdTestUnitId,
      'orientation': orientation,
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
    if (loaded) lastLoadedTime = DateTime.now();
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
  Future<bool> show() async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    ensureAdAvailable();
    return (await channel.invokeMethod<bool>('showAd'))!;
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
