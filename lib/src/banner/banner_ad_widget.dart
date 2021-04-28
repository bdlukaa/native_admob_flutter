import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../native_admob_flutter.dart';
import '../platform_views.dart';
import '../utils.dart';
import 'controller.dart';

const _viewType = 'banner_admob';

/// Creates a BannerAd and add it to the widget tree. Uses
/// a [PlatformView] to connect to the AdView in the platform
/// side. Uses:
///   - https://developers.google.com/admob/android/banner on Android
///   - https://developers.google.com/admob/ios/banner on iOS
class BannerAd extends StatefulWidget {
  /// Creates a new Banner Ad.
  /// `size` can NOT be null. If so, an `AssertionError` is thrown
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad)
  const BannerAd({
    Key? key,
    this.builder,
    this.controller,
    this.size = BannerSize.ADAPTIVE,
    this.error,
    this.loading,
    this.unitId,
    this.options = const BannerAdOptions(),
    this.delayToShow,
    this.loadTimeout = kDefaultLoadTimeout,
    this.nonPersonalizedAds = kDefaultNonPersonalizedAds,
    this.useHybridComposition,
    this.keywords = const [],
  }) : super(key: key);

  /// The builder of the ad. The ad won't be reloaded if this changes
  ///
  /// DO:
  /// ```dart
  /// BannerAd(
  ///   builder: (context, child) {
  ///     return Container(
  ///       // Applies a blue color to the background.
  ///       // You can use anything here to build the ad.
  ///       // The ad won't be reloaded
  ///       color: Colors.blue,
  ///       child: child,
  ///     );
  ///   }
  /// )
  /// ```
  ///
  /// DON'T:
  /// ```dart
  /// Container(
  ///   color: Colors.blue,
  ///   child: BannerAd(),
  /// )
  /// ```
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#adbuilder)
  final AdBuilder? builder;

  /// The error placeholder. If an error happens, this widget will be shown
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#loading-and-error-placeholders)
  final Widget? error;

  /// The loading placeholder. This widget will be shown while the ad is loading
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#loading-and-error-placeholders)
  final Widget? loading;

  /// The controller of the ad.
  /// This controller must be unique and can be used on only one `BannerAd`
  ///
  /// The ad is loaded automatically when attached and it's not necessary to load it
  /// manually.
  /// You can use the controller to reload the ad:
  /// ```dart
  /// controller.load();
  /// ```
  ///
  /// You can use the controller to listen to events:
  /// ```dart
  /// controller.onEvent.listen((e) {
  ///    final event = e.keys.first;
  ///    final info = e.values.first;
  ///    switch (event) {
  ///     case BannerAdEvent.loading:
  ///       break;
  ///     case BannerAdEvent.loadFailed:
  ///       print(info);
  ///       break;
  ///     case BannerAdEvent.loaded:
  ///       break;
  ///     case BannerAdEvent.undefined:
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-banner-events)
  final BannerAdController? controller;

  /// The size of the Ad. `BannerSize.ADAPTIVE` is the default.
  /// This can NOT be null. If so, throws an `AssertionError`
  ///
  /// ## Sizes
  ///
  /// | Name              | `Width`x`Height`   | Availability       |
  /// | ----------------- | ------------------ | ------------------ |
  /// | BANNER            | 320x50             | Phones and Tablets |
  /// | LARGE_BANNER      | 320x100            | Phones and Tablets |
  /// | MEDIUM_RECTANGLE  | 320x250            | Phones and Tablets |
  /// | FULL_BANNER       | 468x60             | Tablets            |
  /// | LEADERBOARD       | 728x90             | Tablets            |
  /// | SMART_BANNER      | `?`x(32, 50, 90)   | Phones and Tablets |
  /// | *ADAPTIVE_BANNER* | `Screen width`x`?` | Phones and Tablets |
  ///
  /// ### Usage
  /// ```dart
  /// BannerAd(
  ///   ...
  ///   size: BannerSize.`Name` /* (`BANNER`, `FULL_BANNER`, etc) */,
  ///   ...
  /// )
  /// ```
  ///
  /// ## Custom size
  /// To define a custom banner size, set your desired `BannerSize`, as shown here:
  /// ```dart
  /// BannerAd(
  ///   ...
  ///                      // width, height
  ///   size: BannerSize.fromWH(300, 50),
  ///   size: BannerSize(Size(300, 50)),
  ///   ...
  /// )
  /// ```
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#creating-an-ad)
  final BannerSize size;

  /// The unitId used by this `BannerAd`.
  /// If changed after loaded the ad will NOT be reloaded with the new ad unit id.\
  ///
  /// If `null`, defaults to `MobileAds.bannerAdUnitId`
  final String? unitId;

  /// The options this ad will follow.
  final BannerAdOptions options;

  /// The duration the platform view will wait to be shown.
  ///
  /// For more info, see [this issue](https://github.com/bdlukaa/native_admob_flutter/issues/11)
  final Duration? delayToShow;

  /// The ad will stop loading after a specified time.
  ///
  /// If `null`, defaults to 1 minute
  final Duration loadTimeout;

  /// Whether non-personalized ads (ads that are not based on a user’s past behavior)
  /// should be enabled.
  final bool nonPersonalizedAds;

  /// {@macro ads.keywords}
  final List<String> keywords;

  /// Use hybrid composition in this ad. This has effect only on Android
  ///
  /// If null, defaults to `MobileAds.useHybridComposition`
  final bool? useHybridComposition;

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd>
    with AutomaticKeepAliveClientMixin<BannerAd> {
  late BannerAdController controller;
  BannerAdEvent state = BannerAdEvent.loading;

  double? height;

  BannerAdOptions get options => widget.options;
  StreamSubscription? _onEventSub;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        BannerAdController(loadTimeout: widget.loadTimeout);
    controller.attach(true);
    _onEventSub?.cancel();
    _onEventSub = controller.onEvent.listen((e) {
      final event = e.keys.first;
      final info = e.values.first;
      switch (event) {
        case BannerAdEvent.loading:
        case BannerAdEvent.loadFailed:
        case BannerAdEvent.loaded:
          if (info is int) height = info.toDouble();
          setState(() => state = event);
          break;
        default:
          break;
      }
    });
    if (!controller.isLoaded) controller.load(timeout: widget.loadTimeout);
  }

  @override
  void didUpdateWidget(BannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.reloadWhenSizeChanges) {
      if (oldWidget.size != widget.size)
        controller.load(timeout: widget.loadTimeout);
    }
    if (widget.options.reloadWhenUnitIdChanges) {
      if ((oldWidget.unitId == null && widget.unitId != null) ||
          (oldWidget.unitId != null && widget.unitId == null) ||
          (oldWidget.unitId != widget.unitId)) {
        controller.load(timeout: widget.loadTimeout);
      }
    }
    // if (oldWidget.controller == null && widget.controller != null) {
    //   attachNewController();
    //   controller.changeController(controller.id);
    //   controller.load();
    // }
  }

  @override
  void dispose() {
    _onEventSub?.cancel();
    _onEventSub = null;
    // dispose the controller only if the controller was
    // created by the ad.
    if (widget.controller == null)
      controller.dispose();
    else
      controller.attach(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assertPlatformIsSupported();
    assertVersionIsSupported();

    return LayoutBuilder(
      builder: (context, consts) {
        double height = widget.size.size.height;
        double width = widget.size.size.width;

        if (height == -1 && width == -1) {
          width = consts.biggest.width;
        }

        final params = <String, dynamic>{};
        params.addAll({
          'controllerId': controller.id,
          'unitId': widget.unitId ?? MobileAds.bannerAdUnitId,
          'size_height': height,
          'size_width': width,
          'nonPersonalizedAds': widget.nonPersonalizedAds,
          'keywords': widget.keywords,
        });

        Widget w;
        if (Platform.isAndroid) {
          w = AndroidPlatformView(
            params: params,
            viewType: _viewType,
            delayToShow: widget.delayToShow,
            useHybridComposition: widget.useHybridComposition,
          );
        } else if (Platform.isIOS) {
          w = UiKitView(
            viewType: _viewType,
            creationParamsCodec: StandardMessageCodec(),
            creationParams: params,
          );
        } else {
          return SizedBox();
        }

        double? finalHeight;
        if (this.height != null && !this.height!.isNegative) {
          finalHeight = this.height;
        } else if (!height.isNegative)
          finalHeight = height;
        else /* if (height == -1 && width == -2) */ {
          final screenHeight = MediaQuery.of(context).size.height;
          double height;
          if (screenHeight <= 400)
            height = 32;
          else if (screenHeight > 400 || screenHeight <= 720)
            height = 50;
          else
            height = 90;
          finalHeight = height;
        }

        w = SizedBox(height: finalHeight, child: w);
        if (state == BannerAdEvent.loaded)
          w = widget.builder?.call(context, w) ?? w;

        w = Stack(children: [
          w,
          () {
            if (!controller.isLoaded) {
              if (state == BannerAdEvent.loading)
                return widget.loading ?? SizedBox();
              if (state == BannerAdEvent.loadFailed)
                return widget.error ?? SizedBox();
            }
            return SizedBox();
          }(),
        ]);

        return w;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
