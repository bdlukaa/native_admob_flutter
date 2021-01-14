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
    this.size = BannerSize.SMART_BANNER,
    // this.error,
    // this.loading,
  })  : assert(size != null),
        super(key: key);

  final AdBuilder builder;

  // final Widget error;
  // final Widget loading;

  final BannerAdController controller;

  /// This can be set only once
  final BannerSize size;

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> {
  BannerAdController controller;
  // BannerAdEvent state = BannerAdEvent.loading;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? BannerAdController();
    controller.attach();
    controller.onEvent.listen((e) {
      final event = e.keys.first;
      // final info = e.values.first;
      switch (event) {
        // case BannerAdEvent.loading:
        // case BannerAdEvent.loadFailed:
        // case BannerAdEvent.loaded:
        //   setState(() => state = event);
        //   break;
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
    // if (state == BannerAdEvent.loading) return widget.loading ?? SizedBox();
    // if (state == BannerAdEvent.loadFailed) return widget.error ?? SizedBox();

    Widget w;

    double height = widget.size.size.height;
    double width = widget.size.size.width;

    if (height == -1 || width == -1) {
      w = LayoutBuilder(builder: (context, consts) {
        width = consts.biggest.width;
        height = null;
        return w;
      });
    }

    final params = <String, dynamic>{};
    params.addAll({
      'controllerId': controller.id,
      'unitId': MobileAds.bannerAdUnitId,
      'size_height': height ?? -1,
      'size_width': width,
    });

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

    if (!height.isNegative)
      w = SizedBox(height: height, child: w);
    else /* if (height == -1 && width == -2) */ {
      final screenHeight = MediaQuery.of(context).size.height;
      double height;
      if (screenHeight <= 400)
        height = 32;
      else if (screenHeight > 400 || screenHeight <= 720)
        height = 50;
      else
        height = 90;
      w = SizedBox(height: height, child: w);
    }

    return widget.builder?.call(context, w) ?? w;
  }
}
