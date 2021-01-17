import 'dart:io';

import 'package:flutter/material.dart';

import '../utils.dart';
import 'controller.dart';

import '../../native_admob_flutter.dart';

const _viewType = "banner_admob";

class BannerAd extends StatefulWidget {
  const BannerAd({
    Key key,
    this.builder,
    this.controller,
    this.size = BannerSize.ADAPTIVE,
    this.error,
    this.loading,
  })  : assert(size != null),
        super(key: key);

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
  final AdBuilder builder;

  /// The error placeholder. If an error happens, this widget will be shown
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#loading-and-error-placeholders)
  final Widget error;

  /// The loading placeholder. This widget will be shown while the ad is loading
  ///
  /// For more info, visit the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-banner-ad#loading-and-error-placeholders)
  final Widget loading;

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
  final BannerAdController controller;

  /// The size of the Ad
  ///
  /// ## Sizes
  ///
  /// | Name             | `Width`x`Height` | Availability       |
  /// | ---------------- | ---------------- | ------------------ |
  /// | BANNER           | 320x50           | Phones and Tablets |
  /// | LARGE_BANNER     | 320x100          | Phones and Tablets |
  /// | MEDIUM_RECTANGLE | 320x250          | Phones and Tablets |
  /// | FULL_BANNER      | 468x60           | Tablets            |
  /// | LEADERBOARD      | 728x90           | Tablets            |
  /// | SMART_BANNER     | `?`x(32, 50, 90) | Phones and Tablets |
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

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> {
  BannerAdController controller;
  BannerAdEvent state = BannerAdEvent.loading;

  double height;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? BannerAdController();
    controller.attach();
    controller.onEvent.listen((e) {
      final event = e.keys.first;
      final info = e.values.first;
      switch (event) {
        case BannerAdEvent.loading:
        case BannerAdEvent.loadFailed:
        case BannerAdEvent.loaded:
          height = (info as int)?.toDouble();
          setState(() => state = event);
          break;
        case BannerAdEvent.undefined:
          setState(() {});
          break;
        default:
          break;
      }
    });

    controller.load();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assertPlatformIsSupported();

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
          'unitId': MobileAds.bannerAdUnitId,
          'size_height': height ?? -1,
          'size_width': width,
        });

        Widget w;
        if (Platform.isAndroid) {
          w = buildAndroidPlatformView(
            params,
            _viewType,
            MobileAds.useHybridComposition,
          );
          // } else if (Platform.isIOS) {
          //   w = UiKitView(
          //     viewType: _viewType,
          //     creationParamsCodec: StandardMessageCodec(),
          //     creationParams: layout,
          //   );
        } else {
          return SizedBox();
        }

        double finalHeight;
        if (this.height != null && !this.height.isNegative) {
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
        w = widget.builder?.call(context, w) ?? w;

        w = Stack(
          children: [
            w,
            if (state == BannerAdEvent.loading) widget.loading ?? SizedBox(),
            if (state == BannerAdEvent.loadFailed) widget.error ?? SizedBox(),
          ],
        );

        return w;
      },
    );
  }
}
