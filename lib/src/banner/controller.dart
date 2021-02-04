import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../mobile_ads.dart';
import '../utils.dart';

enum BannerAdEvent {
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

  /// Called when the event is unkown (usually for rebuilding ui)
  undefined,
}

class BannerSize {
  /// The Size of the Banner.
  final Size size;

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
  /// ![Adaptive Banner](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/banner/adaptive_banner.png)
  static const BannerSize ADAPTIVE = BannerSize(Size(-1, -1));

  /// Standart banner.\
  /// Creates a banner of `320w`x`50h`
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#other-sizes)
  ///
  /// ![Standart Banner](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/banner/standart_banner.png)
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

  /// Creates banner ad with a custom size from `width` and `height`
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
class BannerAdController extends LoadShowAd<BannerAdEvent> {
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
  ///     case BannerAdEvent.clicked;
  ///       print('clicked');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-banner-events#listening-to-events)
  Stream<Map<BannerAdEvent, dynamic>> get onEvent => super.onEvent;

  bool _attached = false;

  /// Check if the controller is attached to a `BannerAd`
  bool get isAttached => _attached;

  /// Creates a new native ad controller
  BannerAdController() : super();

  /// Initialize the controller. This can be called only by the controller
  void init() {
    channel.setMethodCallHandler(_handleMessages);
    MobileAds.pluginChannel.invokeMethod('initBannerAdController', {'id': id});
  }

  /// Attach the controller to a new `BannerAd`. Throws an `AssertionException` if the controller
  /// is already attached.
  ///
  /// You should NOT call this function
  void attach() {
    ensureAdNotDisposed();
    assertControllerIsNotAttached(isAttached);
    _attached = true;
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
    MobileAds.pluginChannel.invokeMethod(
      'disposeBannerAdController',
      {'id': id},
    );
  }

  Future<dynamic> _handleMessages(MethodCall call) async {
    if (isDisposed) return;
    switch (call.method) {
      case 'loading':
        onEventController.add({BannerAdEvent.loading: null});
        break;
      case 'onAdFailedToLoad':
        onEventController.add({
          BannerAdEvent.loadFailed: AdError.fromJson(call.arguments),
        });
        break;
      case 'onAdLoaded':
        onEventController.add({BannerAdEvent.loaded: call.arguments});
        break;
      case 'onAdClicked':
        onEventController.add({BannerAdEvent.clicked: null});
        break;
      case 'onAdImpression':
        onEventController.add({BannerAdEvent.impression: null});
        break;
      case 'undefined':
      default:
        onEventController.add({BannerAdEvent.undefined: null});
        break;
    }
  }

  /// Load the ad. The ad needs to be loaded to be rendered.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-banner-events#reloading-the-ad)
  Future<bool> load() {
    ensureAdNotDisposed();
    assertControllerIsAttached(isAttached);
    assertMobileAdsIsInitialized();
    return channel.invokeMethod<bool>('loadAd', null);
  }
}
