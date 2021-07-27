import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../mobile_ads.dart';
import '../utils.dart';

/// The events a [BannerAdController] can receive. Listen
/// to the events using `controller.onEvent.listen((event) {})`.
///
/// Avaiable events:
///   - impression (When the ad is rendered on the screen)
///   - loading (When the ad starts loading)
///   - loaded (When the ad is loaded)
///   - loadFailed (When the ad failed to load)
enum BannerAdEvent {
  /// Called when an impression is recorded for an ad.
  impression,

  /// Called when an ad request failed.
  loadFailed,

  /// Called when an ad is received.
  loaded,

  /// Called when the ad starts loading
  loading,
}

/// The size of a [BannerAd]. It's highly recommended to use
/// [BannerSize.ADAPTIVE] when creating your [BannerAd]s
class BannerSize {
  /// The Size of the Banner.
  final Size size;

  /// Creates a new Banner Size. To create a custom size from
  /// height and width, use [BannerSize.fromWH(width, height)]
  const BannerSize(this.size);

  /// Smart Banners are ad units that render screen-width banner
  /// ads on any screen size across different devices in either
  /// orientation. Smart Banners detect the width of the device
  /// in its current orientation and create the ad view that size.
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#smart-banners)
  @Deprecated('Smart banner is deprecated in favor of adaptive banner')
  static const BannerSize SMART_BANNER = BannerSize(Size(-1, -2));

  /// Adaptive banners are the next generation of responsive ads,
  /// maximizing performance by optimizing ad size for each device.
  /// Improving on smart banners, which only supported fixed heights,
  /// adaptive banners let developers specify the ad-width and use
  /// this to determine the optimal ad size.
  ///
  /// To pick the best ad size, adaptive banners use fixed aspect ratios
  /// instead of fixed heights. This results in banner ads that occupy a
  /// more consistent portion of the screen across devices and provide
  /// opportunities for improved performance.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#adaptive-banners)
  ///
  /// ![Adaptive Banner](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/banner/adaptive_banner.png?raw=true)
  static const BannerSize ADAPTIVE = BannerSize(Size(-1, -1));

  /// Standart banner.\
  /// Creates a banner of `320w`x`50h`
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#other-sizes)
  ///
  /// ![Standart Banner](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/banner/standart_banner.png?raw=true)
  static const BannerSize BANNER = BannerSize(Size(320, 50));

  /// Large banner.\
  /// Creates a banner of `320w`x`100h`
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#other-sizes)
  static const BannerSize LARGE_BANNER = BannerSize(Size(320, 100));

  /// Medium Rectangle.\
  /// Creates a banner of `320w`x`250h`\
  /// Avaiable only on Tablets
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#other-sizes)
  static const BannerSize MEDIUM_RECTANGLE = BannerSize(Size(320, 250));

  /// Full banner.\
  /// Creates a banner of `468w`x`60h`\
  /// Avaiable only on Tablets
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#other-sizes)
  static const BannerSize FULL_BANNER = BannerSize(Size(468, 60));

  /// LEADERBOARD.\
  /// Creates a banner of `728w`x`90h`
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#other-sizes)
  static const BannerSize LEADERBOARD = BannerSize(Size(728, 90));

  /// Creates banner ad with a custom size from `width` and `height`.
  /// Keep in mind that the ad may not fit well with custom sizes
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#custom-size)
  factory BannerSize.fromWH(double width, double height) {
    return BannerSize(Size(width, height));
  }

  @override
  String toString() => '${size.width}x${size.height}';
}

/// An Banner Ad Controller model to communicate with the model on the platform side.
/// It gives you methods to help in the implementation and event tracking.
/// It's supposed to work alongside `BannerAd`, the class used to show the ad in
/// the UI and add it to the widget tree.
///
/// For more info, see:
///   - https://developers.google.com/admob/android/banner
///   - https://developers.google.com/admob/ios/banner
class BannerAdController extends LoadShowAd<BannerAdEvent>
    with AttachableMixin {
  /// The test id for this ad.
  ///   - Android: ca-app-pub-3940256099942544/6300978111
  ///   - iOS: ca-app-pub-3940256099942544/2934735716
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#always-test-with-test-ads)
  static String get testUnitId => MobileAds.bannerAdTestUnitId;

  /// Listen to the events the controller throws
  ///
  /// Usage:
  /// ```dart
  /// controller.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case BannerAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case BannerAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case BannerAdEvent.loadFailed:
  ///       final errorCode = e.values.first;
  ///       print('loadFailed $errorCode');
  ///       break;
  ///     case BannerAdEvent.impression:
  ///       print('ad rendered');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-banner-events#listening-to-events)
  Stream<Map<BannerAdEvent, dynamic>> get onEvent => super.onEvent;

  /// Creates a new native ad controller
  BannerAdController({
    Duration loadTimeout = kDefaultLoadTimeout,
    Duration timeout = kDefaultAdTimeout,
  }) : super(
          loadTimeout: loadTimeout,
          timeout: timeout,
        );

  /// Initialize the controller. This can be called only by the controller
  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initBannerAdController', {'id': id});
  }

  /// Dispose the controller to free up resources.
  /// Once disposed, the controller can not be used anymore
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
    MobileAds.pluginChannel.invokeMethod('disposeBannerAdController', {
      'id': id,
    });
    attach(false);
  }

  Future<dynamic> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    switch (call.method) {
      case 'loading':
        isLoaded = false;
        onEventController.add({BannerAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        isLoaded = false;
        onEventController.add({
          BannerAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdLoaded':
        isLoaded = true;
        onEventController.add({BannerAdEvent.loaded: call.arguments});
        break;
      case 'onAdImpression':
        onEventController.add({BannerAdEvent.impression: null});
        break;
      default:
        break;
    }
  }

  /// Load the ad. The ad needs to be loaded to be rendered.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-banner-events#reloading-the-ad)
  Future<bool> load({
    /// Force to load an ad even if another is already avaiable
    bool force = false,

    /// The timeout of this ad. If null, defaults to 1 minute
    Duration? timeout,
  }) async {
    ensureAdNotDisposed();
    assertMobileAdsIsInitialized();
    if (!debugCheckAdWillReload(isLoaded, force)) return false;
    isLoaded = (await channel.invokeMethod<bool>('loadAd').timeout(
      timeout ?? this.loadTimeout,
      onTimeout: () {
        if (!onEventController.isClosed && !isLoaded)
          onEventController.add({
            BannerAdEvent.loadFailed: AdError.timeoutError,
          });
        return false;
      },
    ))!;
    if (isLoaded) lastLoadedTime = DateTime.now();
    return isLoaded;
  }
}
